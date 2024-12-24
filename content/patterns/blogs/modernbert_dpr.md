+++
title = "Reproducibility Report of ModernBERT Models for Retrieval Tasks Using DPR"
toc = true
tags = ["retrieval", "llm"]
+++


> Cross-posted here: https://api.wandb.ai/links/joe32140/zqs87nz3


# Before We Start

As researchers from LightOn.AI and Answer.AI released the ModernBERT models (https://huggingface.co/papers/2412.13663 ), which are BERT models for 2024, I am interested to see its performance on retrieval tasks as mentioned in their paper, specifically with DPR. However, they have not released the model checkpoints for all experiments. I decided to finetune ModernBERT on the MSMACRO dataset by myself based on the provided training scripts.


# Experiments

I ran experiments with [the official training scripts](https://github.com/AnswerDotAI/ModernBERT/tree/main/examples), modifying the mini_batch_size for `CachedMultipleNegativesRankingLoss` to accelerate the training. Following the hyperparameter suggestions, I chose a learning rate of 8e-5 for the base model and 1e-4 for the large model. The per_device_batch_size was set to 512, which is different from the batch size of 16 mentioned in the paper. By training both model sizes on an RTX4090 24GB GPU, it took 1 hour for the base model and 2 hours for the large model for one epoch. More training logs are shown in the panels below. 

In the end, I finetuned ModernBERT-base and ModernBERT-large on 1.25M partial training instances on [the MSMACRO dataset](https://huggingface.co/datasets/sentence-transformers/msmarco-co-condenser-margin-mse-sym-mnrl-mean-v1) following the paper's experiment setup. I put the fine-tuned checkpoint on Hugging Face Hub:

https://huggingface.co/collections/joe32140/modernbert-for-retrieval-6764ff19edb01fb6c69538f0

# Reproduced Results

As shown in the table below, my fine-tuned models outperform the original models reported in the paper on NDCG@10. My fine-tuned models even improve the ArguAna dataset by more than 10% for the base model and 9% for the large model. I hypothesize that the performance gains come from the much larger batch size of 512 in the official training script compared to the reported batch size of 16 in the paper, but this needs to be verified by the authors. 

For the out-of-domain (OOD) evaluation on the MLDR dataset, our models still show significant improvement over the original numbers. 

It's worth noting that if you finetune the model on the whole MSMACRO dataset with the same suggested learning rate, the model performance degrades significantly, which could be due to overfitting the training dataset.



|                         	| NFCorpus 	| SciFact 	| TREC-Covid 	|  FiQA 	| ArguAna 	| SciDocs 	| FEVER 	| Climate-FEVER 	| MLDR - OOD 	|
|:-----------------------:	|:--------:	|:-------:	|:----------:	|:-----:	|:-------:	|:-------:	|-------	|---------------	|:----------:	|
| ModernBERT-base         	| 23.7     	| 57.0    	| 72.1       	| 28.8  	| 35.7    	| 12.5    	| 59.9  	| 23.6          	| 27.4       	|
| ModernBERT-base (ours)  	| 26.6    	| 61.6   	| 71.4      	| 30.7 	| 46.3   	| 13.6   	| 65.7  	| 22.6          	| 30.5      	|
| ModernBERT-large        	| 26.2     	| 60.4    	| 74.1       	| 33.1  	| 38.2    	| 13.8    	| 62.7  	| 20.5          	| 34.3       	|
| ModernBERT-large (ours) 	| 28.4    	| 63.6   	| 77.4      	| 34.3 	| 47.7   	| 15.7   	| 68.2  	| 22.9          	| 38.9      	|

# Bottom Line

Overall, my attempt to reproduce experiment results on the newly proposed ModernBERT for retrieval tasks was more than successful, with my fine-tuned models outperforming the numbers reported in the original paper by a large margin. This gap may come from the batch size discrepancy between the provided training script and that in the paper, i.e., 512 in the script vs. 16 in the paper. 

Please try the fine-tuned retrieval models yourself at my [Huggingface model hub](https://huggingface.co/collections/joe32140/modernbert-for-retrieval-6764ff19edb01fb6c69538f0)!






