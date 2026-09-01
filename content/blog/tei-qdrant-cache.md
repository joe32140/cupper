+++
title = "My Attempt at Building a Multi-GPU Embedding Server with TEI and Qdrant"
subtitle = "Serving an embedding model across several GPUs turned out to have no one-click answer. This is the stack I landed on: TEI behind Nginx, with a FastAPI proxy caching embeddings in Qdrant."
description = "Why there's no one-click multi-GPU embedding server in 2025, and the TEI + Nginx + FastAPI + Qdrant stack I ended up building instead."
date = 2025-04-06
toc = true
aliases = ["/patterns/blogs/tei_qdrant_cache/"]
tags = ["retrieval", "llm", "embeddings", "inference", "caching", "qdrant", "fastapi", "multi-gpu", "llm-infra"]
[sitemap]
  changefreq = "monthly"
  priority = 0.8
+++

> GitHub repo: https://github.com/joe32140/tei-qdrant-cache

## Before We Start
Serving an LLM-based embedding model with replicas across multiple GPUs on the same machine might sound trivial today (2025), but after my extensive search, there's actually no one-click setup. Originally, I thought vLLM could easily fulfill my needs, or that SGLang could be an alternative if vLLM didn't work. However, both libraries turned out to be either limited to specific models or unable to route requests across multiple GPUs. Luckily, I came across [vLLM's Nginx deployment guide](https://docs.vllm.ai/en/latest/deployment/nginx.html) and [this comment on the TEI issue tracker](https://github.com/huggingface/text-embeddings-inference/issues/87#issuecomment-1822970062), which led me to an Nginx load balancer setup. It also turned out that Hugging Face has its own [text-embeddings-inference](https://github.com/huggingface/text-embeddings-inference/tree/main) library, which provides seamless support for serving embedding models with pre-built Docker images. In this post, my goal was to create a robust system for serving text embeddings using Hugging Face's text-embeddings-inference (TEI) server, specifically targeting multi-GPU setups and incorporating a mechanism to handle repeated requests efficiently by building a smart caching layer.

The following sections detail the iterative process and the final architecture using TEI, FastAPI, Qdrant, Nginx, and Docker Compose.

## The Initial Plan: Scaling TEI

The starting point was TEI, a high-performance server for embeddings. The immediate need was scaling across multiple GPUs (a 2-GPU machine in my case). TEI's issue discussion suggested a pattern: run independent TEI instances, each pinned to a specific GPU, and place a load balancer like Nginx in front ([issue #87](https://github.com/huggingface/text-embeddings-inference/issues/87#issuecomment-1822970062)). 

To manage this, I opted for Docker Compose and wrote a Python script (`generate_configs.py`) to dynamically create the `docker-compose.yml` and `nginx.conf` based on a simple `.env` file specifying the number of GPU replicas (`NUM_REPLICAS`). This made scaling up or down much easier than manually duplicating service definitions.

![Architecture diagram: an Nginx load balancer distributing embedding requests across two GPU-pinned TEI instances.](/images/tei_lb.png "Initial simplified view: the Nginx load balancer distributing requests across one TEI instance per GPU.")

## The Caching Idea: Handling Redundancy

With the basic multi-GPU serving working, the next goal was efficiency. Many applications send the same text for embedding multiple times. Re-computing these is wasteful. A caching layer was needed.

I considered options like Nginx+Lua but opted for a dedicated **FastAPI proxy service** placed *in front* of the Nginx load balancer. This offered better separation of concerns and more flexibility in implementing the caching logic. For the cache store itself, instead of a simple key-value store like Redis, I decided to experiment with **Qdrant**, a vector database. While slightly overkill for simple key-value lookups, it offered persistence and the potential for future vector-based operations on the cache itself.

The plan was:
*   Client sends request to FastAPI proxy.
*   Proxy hashes the input text to create a key.
*   Proxy checks Qdrant for this key.
*   **Hit:** Return cached embedding.
*   **Miss:** Forward *only the missed text(s)* to Nginx → TEI, get the embedding, store it in Qdrant, then return to the client.

## The Final Stack & A Gradio Demo

After these iterations, the final architecture emerged:

![Architecture diagram: client requests hit a FastAPI proxy, which checks a Qdrant cache before forwarding misses through Nginx to the TEI instances.](/images/tei_qdrant_lb.png?wide "The final stack: a FastAPI caching proxy in front of the Nginx load balancer, with Qdrant as the cache store.")

To make interaction easier, I added a simple [**Gradio application**](https://github.com/joe32140/tei-qdrant-cache/tree/main/gradio_code_search) that uses this backend. It can clone a GitHub repo or scan a local directory, chunk code files, call the embedding endpoint (hitting the cache proxy), store the results in its *own* local Qdrant instance (separate from the main cache), and allow semantic search over the indexed code chunks. It works fine! (See the example below.)

![Screenshot of the Gradio app showing semantic code search results over an indexed GitHub repository.](/images/ui.png "The Gradio demo: clone a repo, chunk and embed the files through the cache proxy, then search the chunks semantically.")

## Bottom Line & Takeaways

Building this `tei-qdrant-cache` system was a valuable journey through the practicalities of deploying and optimizing embedding models. Key takeaways include:

*   **Infrastructure First:** Correct Docker, GPU driver, and NVIDIA Container Toolkit setup is paramount.
*   **Know Your Tools:** Understand the requirements and limitations of components like TEI (model compatibility, token limits) and libraries like `qdrant-client` (sync vs. async, ID formats).
*   **Caching Benefits:** A caching layer significantly improves performance for repeated inputs, but its implementation requires careful handling of cache misses and potential downstream bottlenecks.
*   **Batching is Key:** When dealing with downstream services (like TEI) that have input size limits, implementing client-side batching in the proxy/application layer is essential.
*   **Iterative Development:** Expect to hit roadblocks and refine the architecture based on errors and performance observations.

The final result is a scalable, persistent, and significantly faster embedding service for workloads with potential query repetition.

Check out the [full implementation](https://github.com/joe32140/tei-qdrant-cache) and try it yourself!
