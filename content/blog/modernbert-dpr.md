+++
title = "Reproducibility Report of ModernBERT Models for Retrieval Tasks Using DPR"
subtitle = "The ModernBERT paper didn't ship checkpoints for the retrieval experiments, so I fine-tuned them myself. The reproduced numbers came out above the published ones on nearly every dataset."
description = "Fine-tuning ModernBERT-base and -large on MS MARCO with DPR. The reproduced NDCG@10 beats the paper's reported numbers on nearly every dataset — batch size looks like the reason."
date = 2024-12-24
toc = true
aliases = ["/patterns/blogs/modernbert_dpr/"]
tags = ["retrieval", "llm", "embeddings", "reproducibility", "modernbert"]
[sitemap]
  changefreq = "monthly"
  priority = 0.8
+++


> Cross-posted here: https://api.wandb.ai/links/joe32140/zqs87nz3


## Before We Start

As researchers from LightOn.AI and Answer.AI released the [ModernBERT models](https://huggingface.co/papers/2412.13663), a BERT redesigned for 2024, I was interested to see its performance on retrieval tasks as mentioned in their paper, specifically with DPR. However, they had not released the model checkpoints for all experiments. I decided to fine-tune ModernBERT on the MS MARCO dataset by myself based on the provided training scripts.


## Experiments

I ran experiments with [the official training scripts](https://github.com/AnswerDotAI/ModernBERT/tree/main/examples), modifying the `mini_batch_size` for `CachedMultipleNegativesRankingLoss` to accelerate the training. Following the hyperparameter suggestions, I chose a learning rate of 8e-5 for the base model and 1e-4 for the large model. The `per_device_batch_size` was set to 512, which is different from the batch size of 16 mentioned in the paper. By training both model sizes on an RTX4090 24GB GPU, it took 1 hour for the base model and 2 hours for the large model for one epoch. More training logs are available in [the W&B report](https://api.wandb.ai/links/joe32140/zqs87nz3). 

In the end, I fine-tuned ModernBERT-base and ModernBERT-large on 1.25M training instances from [the MS MARCO dataset](https://huggingface.co/datasets/sentence-transformers/msmarco-co-condenser-margin-mse-sym-mnrl-mean-v1) following the paper's experiment setup. I put the fine-tuned checkpoints on the Hugging Face Hub:

[joe32140/modernbert-for-retrieval](https://huggingface.co/collections/joe32140/modernbert-for-retrieval-6764ff19edb01fb6c69538f0)

## Reproduced Results

As shown in the table below, my fine-tuned models outperform the original models reported in the paper on NDCG@10 for almost every dataset — the exceptions are TREC-Covid and Climate-FEVER for the base model. They also improve performance on the ArguAna dataset by more than 10 points for the base model and 9 points for the large model. I hypothesize that these gains come from the much larger batch size of 512 in the official training script, compared to the reported batch size of 16 in the paper, but this still needs verification by the authors.

For the out-of-domain (OOD) evaluation on the MLDR dataset, my models improve clearly over the original numbers.

It's worth noting that if you fine-tune the model on the entire MS MARCO dataset with the same suggested learning rate, the performance degrades noticeably, which could be due to overfitting.

Since my fine-tuned versions beat the reported results on nearly every dataset, I also tested the `gte-en-mlm-base` model. It still shows substantial improvements, suggesting that the difference in batch size may be a key factor behind these gains.

|                         | NFCorpus | SciFact | TREC-Covid | FiQA | ArguAna | SciDocs | FEVER | HotpotQA | Climate-FEVER | MLDR - OOD |
|:-----------------------:|:--------:|:-------:|:----------:|:----:|:-------:|:-------:|:-----:|:--------:|:-------------:|:----------:|
| gte-en-mlm-base         | 26.3     | 54.1    | 49.7       | 30.1 | 35.7    | 14.1    | 65.0  | 49.9     | 22.9          | 34.3       |
| ModernBERT-base         | 23.7     | 57.0    | 72.1       | 28.8 | 35.7    | 12.5    | 59.9  | 46.1     | 23.6          | 27.4       |
| ModernBERT-large        | 26.2     | 60.4    | 74.1       | 33.1 | 38.2    | 13.8    | 62.7  | 49.2     | 20.5          | 34.3       |
| gte-en-mlm-base (ours)  | 29.7     | 60.2    | 57.2       | 31.9 | 48.7    | 15.2    | 67.7  | 50.8     | 24.9          | 35.0       |
| ModernBERT-base (ours)  | 26.6     | 61.6    | 71.4       | 30.7 | 46.3    | 13.6    | 65.7  | 47.8     | 22.6          | 30.5       |
| ModernBERT-large (ours) | 28.4     | 63.6    | 77.4       | 34.3 | 47.7    | 15.7    | 68.2  | 51.8     | 22.9          | 38.9       |

## Bottom Line

Overall, my attempt to reproduce experiment results on the newly proposed ModernBERT for retrieval tasks was successful, with my fine-tuned models outperforming the numbers reported in the original paper by a large margin. This gap may come from the batch size discrepancy between the provided training script and that in the paper, i.e., 512 in the script vs. 16 in the paper. Even though the numbers for ModernBERT and gte-en-mlm are close or mixed on retrieval tasks using DPR, both training and inference are much faster with ModernBERT. Thus, I would still recommend using ModernBERT in most cases.

Please try the fine-tuned retrieval models by yourself at my [Hugging Face collection](https://huggingface.co/collections/joe32140/modernbert-for-retrieval-6764ff19edb01fb6c69538f0)!






