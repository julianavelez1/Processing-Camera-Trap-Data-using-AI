---
title: "Camera-trap data"
author: "Juliana Vélez"
date: "11/16/2021"
output: html_document
---



# Camera-trap data

We evaluated model performance using data from a camera trap survey performed from January - July 2020 for wildlife detection within the private natural reserves El Rey Zamuro (31 km2) and Las Unamas (40 km2), located in the Meta department in the Orinoquía region in central Colombia. During the survey period, we collected 112,247 images from a 50-camera-trap array, with cameras spaced 1-km apart; 20 percent of the images were blank and 80 percent contained at least one animal. Records containing the "Vehicle" and "Human" classes were removed from the data set; these were predominately associated with images during camera setup.

Images were stored and reviewed by experts using the Wildlife Insights platform. Wildlife Insights was chosen because it provides advanced processing capabilities that helped to accelerate image review (e.g., multiple image selection, image editing and infrastructure for collaborative data processing).  Expert (i.e., human vision) labels were compared to predictions derived from AI models associated with Wildlife Insights (downloaded in July 2022), MegaDetector (MDv4.1) and MLWIC2 (v1.0) platforms to determine how well these models would perform when applied to data that were not included in the training data set. 

