---
title: "Introduction"
author: "Juliana Vélez"
date: "3/24/2021"
output: html_document
---



# Introduction

Our objectives in writing this guideline are to:

1. Describe the steps needed to set up and process camera trap data using popular artificial intelligence (AI) platforms, including Wildlife Insights, MegaDetector, MLWIC2, and Conservation AI.  

2. Demonstrate common workflows for analyzing camera trap data using these platforms via a case study in which we process data collected by the lead author. The aim of the case study project is to develop a joint species distribution model integrating data from camera traps and acoustic sensors to understand interactions between wildlife species in multi-functional landscapes in Colombia that support both biological diversity and economic activities such as cattle ranching.

Each chapter covers a different AI system, and we provide appropriate links to instruction manuals and other resources for researchers looking for additional documentation. We describe the steps required to set up the platforms, upload pictures (e.g., required folder structure), and include and format metadata (e.g., geographical coordinates of locations, deployment dates, and other deployment information such as camera height, use of bait, etc.). We then provide guidance on how to use the artificial intelligence platforms for object detection (e.g., to separate blanks from non-blanks) and species classification. 

Importantly, we also demonstrate methods for evaluating the performance of AI platforms. Before AI platforms can be evaluated, users will need to manually label a subset of images which can then be compared with AI output. This labeling can be done using a variety of available software [e.g., @scotson2017best], but the resulting data should include, at minimum, the 1) image filename, 2) camera location and 3) species name. The first two variables (e.g., filename and location) are needed to match records from the human-labeled and AI-labeled data sets (hereafter human and computer vision, respectively), and the third variable will allow one to compare human and AI-generated labels. 

Having a subset of labeled images will allow you to assess how a particular AI model is performing with your data set and determine appropriate use given its performance. We provide annotated R code and examples demonstrating how to compute  model performance metrics estimated using categories described in Table \@ref(tab:notation) that classify correct and incorrect predictions.

<!--html_preserve--><table class="huxtable" style="border-collapse: collapse; border: 0px; margin-bottom: 2em; margin-top: 2em; ; margin-left: auto; margin-right: auto;  " id="tab:notation">
<caption style="caption-side: top; text-align: center;">(#tab:notation) Notation and categories of classifications used to estimate model performance metrics.</caption><col><col><tr>
<th style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: bold;">Notation</th><th style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: bold;">Description</th></tr>
<tr>
<td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">TP - True Positives</td><td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">Number of observations where the species was correctly identified as being present in the photo.</td></tr>
<tr>
<td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">TN - True Negatives</td><td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">Number of observations where the species was correctly identified as being absent in the photo.</td></tr>
<tr>
<td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">FP - False Positives</td><td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">Number of observations where the species was absent, but the AI classified the species as being present.</td></tr>
<tr>
<td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">FN - False Negatives</td><td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">Number of observations where the species was present, but the AI classified the species as being absent.</td></tr>
</table>
<!--/html_preserve-->

Performance metrics include model accuracy, precision, recall and F1 score [Table \@ref(tab:intro-metrics); @sokolova_2009]. To describe these metrics, we will refer to AI classifications as "predictions" and human vision classifications as "true classifications". *Accuracy* is the proportion of correct AI predictions in the data set [@R-yardstick], *precision* is the probability that the species is present given it is predicted to be present, and *recall* is the probability a species is predicted to be present given it is truly present; *F1 score* is a weighted average of precision and recall  (Table \@ref(tab:intro-metrics)). When inspecting model performance, it can be useful to calculate these metrics separately for each species.
 
`
<!--html_preserve--><table class="huxtable" style="border-collapse: collapse; border: 0px; margin-bottom: 2em; margin-top: 2em; ; margin-left: auto; margin-right: auto;  " id="tab:intro-metrics">
<caption style="caption-side: top; text-align: center;">(#tab:intro-metrics) Metrics used to assess model performance</caption><col><col><col><tr>
<th style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: bold;">Metrics</th><th style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: bold;">Equation</th><th style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: bold;">Interpretation</th></tr>
<tr>
<td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">Accuracy</td><td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">(TP+TN)/(TP+FP+TN+FN)</td><td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">Proportion of correct predictions in a data set.</td></tr>
<tr>
<td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">Precision</td><td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">TP/(TP+FP)</td><td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">Probability the species is correctly classified as present given that the AI system classified it as present.</td></tr>
<tr>
<td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">Recall</td><td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">TP/(TP+FN)</td><td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">Probability the species is correctly classified as present given that the species truly is present.</td></tr>
<tr>
<td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">F1 Score</td><td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">2*precision*recall / (precision + recall)</td><td style="vertical-align: top; text-align: left; white-space: normal; padding: 6pt 6pt 6pt 6pt; font-weight: normal;">Weighted average of precision and recall.</td></tr>
</table>
<!--/html_preserve-->

AI platforms typically assign a *confidence level* to each classification, with higher values reflective of more certain classifications. These confidence levels can be used to post-process the data in a way that trades off precision and recall.  For example, one can choose to only accept classifications that have a high level of confidence.  Doing so will typically reduce the number of false positives, leading to high levels of precision (i.e., users can be more confident that the species is truly present when AI returns a species classification). The number of true positives, and thus recall, may also be reduced but hopefully to a lesser extent.   
