---
title: "Introduction"
author: "Juliana Vélez"
date: "3/24/2021"
output: html_document
---



# MLWIC2: Machine Learning for Wildlife Image Classification

MLWIC2 is an R package that allows you either to use trained models for identifying species from North America (using the species model) or to identify empty images (using the empty_animal model) [@tabak_2020]. The model was trained using images from 10 states across the United States but was also tested in out-of sample data sets obtaining a 91% accuracy for species from Canada and 91% - 94% for classifying empty images on samples from different continents [@tabak_2020].

Documentation for using MLWIC2 and the list of species that the model identifies can be found in the GitHub repository <https://github.com/mikeyEcology/MLWIC2>. In this chapter we illustrate the use of the package and data preparation for model training.

## Set-up

First, you will need to install R software, Anaconda Navigator (<https://docs.anaconda.com/anaconda/navigator/>), Python (3.5, 3.6 or 3.7) and Rtools (only for Windows computers). Then you will have to install Tensorflow 1.14 and find the path location of Python on your computer.
You can find more installation details in the GitHub repository (<https://github.com/mikeyEcology/MLWIC2>), as well as an example with installation steps for Windows users (<https://github.com/mikeyEcology/MLWIC_examples/blob/master/MLWIC_Windows_Set_up.md>).

Make sure to install the required versions listed above. Mac users can use the Terminal Application to install Python and Tensorflow. You can use the conda package (<https://docs.conda.io/en/latest/>) to create an environment that can host a specific version of Python and keep it separated from other packages or dependencies. In the Terminal type: 

`conda create -n ecology python=3.5`

`conda activate ecology`

`conda install -c conda-forge tensorflow=1.14`


Once you complete the installation of Python and Tensorflow, use the command-line utility to find the location of Python. Windows users should type: `where python`.  Mac users should type `conda activate ecology` and then `which python`.
  
The output Python location will look something like this: `/Users/julianavelez/opt/anaconda3/envs/ecology/bin/python`

In R, install the `devtools` package and `MLWIC2` packages. Then, setup your environment using the `setup` function [@tabak_2020] as shown below, making sure to change the `python_loc` argument to point to the output path provided in the previous step. You will only need to specify this setup once.


```r
# Uncomment and only run this code once
# if (!require('devtools')) install.packages('devtools')
# devtools::install_github("mikeyEcology/MLWIC2")
# MLWIC2::setup(python_loc = "/Users/julianavelez/opt/anaconda3/envs/ecology/bin/")
```

Next, download MLWIC2 helper files from here: <https://drive.google.com/file/d/1VkIBdA-oIsQ_Y83y0OWL6Afw6S9AQAbh/view>. Note, this folder is not included in the repository because of its large size. You must download it and store it in the `data/mlwic2` directory.

## Upload/format data {#format-mlwic2}

Once the package is installed and the python location is setup, you can run a MLWIC2 model to obtain computer vision predictions of the species present in your images. To run MLWIC2 models, you should use the `classify` function (see Section \@ref(mlwic2-ai-module)), which requires arguments specifying the path  (i.e., location on your computer) for the following three inputs:

1. The images that will be classified.
2. The filenames of your images.
3. The location of the MLWIC2 helper files that contain the model information.

To create the filenames (input 2 above), you will need to create an input file using the `make_input` function [@tabak_2020]. This will create a CSV file with two columns, one with the filenames and the other one with a list of class_ID's required to use MLWIC2 for classifying images or training a model. When using the `make_input` function to create the CSV file, you can select different options depending whether or not you already have filenames and images classified (type `?make_input` in R for more options). 

We will use `option = 4` to find filenames associated with each photo using MLWIC2 and `recursive = TRUE` to specify that photos are in subfolders organized by camera location. We then read the output using the `read_csv` function [@R-tidyverse]. Let's first load required libraries for reading data and to use MLWIC2 functions.


```r
library(tidyverse) # for data wrangling and visualization, includes dplyr
library(MLWIC2)
library(here) # to allow the use of relative paths while reading data
```

When using the `make_input` function with your data, you must provide the paths indicating the location of your images (`path_prefix`) and the output directory where you want to store the output. The `make_input` function will output a file named `image_labels.csv` which we renamed as `images_names_classify.csv` and included it with the files associated with this repository. We provide a full illustration of the use of `make_input` and `classify` in Section \@ref(classify-trained) using a small image set included in the repository.



```r
# The code below won't be executed. For using it you must replace:
# - the "path_prefix" with the path to the directory holding your images
# - the "output_directory" with the directory where you want to store the output
#   from running MLWIC2 
make_input(path_prefix = "/Volumes/ct-data/CH1/jan2020",
           recursive = TRUE,
           option = 4,
           find_file_names = TRUE,
           output_dir = here("data", "mlwic2"))

file.rename(from = "data/mlwic2/image_labels.csv", to = "data/mlwic2/images_names_classify.csv")
```

We then read in this file containing the image filenames and look at the first few records. We will use the here package [@here] to tell R that our file lives in the `./data/mlwic2` directory and specify the name of our file `images_names_classify.csv`.


```r
# inspect output from the make_input function
image_labels <- read_csv(here("data","mlwic2","images_names_classify.csv")) 
head(image_labels)
```

```
## # A tibble: 6 × 2
##   `A01/01080001.JPG`   `0`
##   <chr>              <dbl>
## 1 A01/01080002.JPG       0
## 2 A01/01080003.JPG       0
## 3 A01/01080004.JPG       0
## 4 A01/01080005.JPG       0
## 5 A01/01080006.JPG       0
## 6 A01/01080007.JPG       0
```

## Process images - AI module {#mlwic2-ai-module}

Once you have the CSV file with image filenames (`images_names_classify.csv`), you can proceed to run the MLWIC2 models. It is possible to use parallel computing to run the models more efficiently. This will require specifying a number of cores that you want to use while running the models. To do that, first you need to know how many cores (i.e., processors in your computer) are available, which you can determine using the `detectCores` function in the `parallel` package  [@R-base].



```r
library(parallel)
detectCores() # detects number of cores in your computer
```

```
## [1] 4
```

If you have 4 cores, then you can use 3 cores for running the MLWIC2 model using the `classify` function [@tabak_2020] and the `num_cores` argument. This assures that you leave one core for your computer to perform other tasks.

Other arguments for the `classify` function include:

- `path_prefix`: absolute path of the location of your camera trap photos. 
- `data_info`: absolute path of the `images_names_classify.csv` file (i.e., the output from the `make_input` function).  
- `model_dir`: absolute path of MLWIC2 helper files folder.
- `python_loc`: absolute path of Python on your computer.
- `os`: specification of your operating system (here "Mac").
- `make_output`: use TRUE for a ready-to-read CSV output.

To complete this step, you would need to change the file paths to indicate where the files are located on your computer. Note that this step took approximately 5 hours to process 112,247 photos (run on a macOS Mojave with a 2.5 GHz Intel Core i5 Processor and 8GB 1600 MHz DDR3 of RAM).


```r
classify(path_prefix = "/Volumes/ct-data/CH1/jan2020/",
         data_info = here("data", "mlwic2", "images_names_classify.csv"),
         model_dir = here("data", "mlwic2", "MLWIC2_helper_files/"),
         python_loc = "/Users/julianavelez/opt/anaconda3/envs/ecology/bin/", # absolute path of Python on your computer
         os = "Mac", # specify your operating system; "Windows" or "Mac"
         make_output = TRUE,
         num_cores = 3
         )
```

## Assessing AI performance {#ai-mlwic2}

As with other AI platforms, it is recommended to evaluate model performance with your particular data set before using an AI model to classify all your images. This involves classifying a subset of your photos and comparing those classifications with predictions provided by MLWIC2 (i.e., we will compare human vs. computer vision). Let's start by formatting the human vision data set.

### Format human vision data set

To read the file containing the human vision classifications for a subset of images, we tell R the path (i.e., directory name) that holds our file.  Again, we use the `here` package [@here] to tell R that our file lives in the `./data/mlwic2` directory and specify the name of our file `images_hv_jan2020.csv`. You may, alternatively, type in the full path to the file folder or a relative path from the root directory if you are using a project in Rstudio. We then read our file using the `read_csv` function [@R-tidyverse]. 

The human vision data set (`images_hv_jan2020.csv`) was previously cleaned to remove duplicated records and to summarise multiple rows that reference animals of the same species identified in the same image (see Chapter [3][Wildlife Insights (WI)] for details about these steps). If there are multiple species in an image, then you may have multiple rows associated with each detection.  In the Wildlife Insights, we demonstrated methods for evaluating AI performance that considered the possibility of detecting multiple species in an image. However, we can simplify the process of evaluating AI performance if we filter the data to include a single record (e.g., the first object) for each image. To keep a single record per image, we first group rows by `deployment_id`, `filename`, `timestamp` (key columns that identify an image) and then use the `slice` function [@R-dplyr].  This step drops 44 observations, reducing the data set from 104,826 classifications to 104,782 classifications.

We use "pipes" (`%>%`) from the `magrittr` package [@magrittr]. Pipes (`%>%`) provide a way to execute a sequence of data operations, organized so that the operations can be read from left to right (e.g., "Take the file and then group rows using `group_by`").



```r
human_vision <- read_csv(here("data", "mlwic2", "images_hv_jan2020.csv"))

# number of rows prior to dropping records associated with multiple species
# in an image
nrow(human_vision) 
```

```
## [1] 104826
```

```r
human_vision <- human_vision %>% 
  group_by(deployment_id, filename, timestamp) %>% # select first row
  slice(1) # Keep only one row per image

# Number of records after dropping records associated with multiple species
# in an image
nrow(human_vision)
```

```
## [1] 104782
```

```r
# Inspect the first few rows of the data set 
head(human_vision)
```

```
## # A tibble: 6 × 4
## # Groups:   deployment_id, filename, timestamp [6]
##   deployment_id       filename     timestamp           common_name
##   <chr>               <chr>        <dttm>              <chr>      
## 1 A01-Jan2020-Jul2020 01090079.JPG 2020-01-09 10:54:39 Blank      
## 2 A01-Jan2020-Jul2020 01090080.JPG 2020-01-09 10:54:40 Blank      
## 3 A01-Jan2020-Jul2020 01090081.JPG 2020-01-09 10:54:41 Blank      
## 4 A01-Jan2020-Jul2020 01090082.JPG 2020-01-09 10:54:49 Blank      
## 5 A01-Jan2020-Jul2020 01090083.JPG 2020-01-09 10:54:50 Blank      
## 6 A01-Jan2020-Jul2020 01090084.JPG 2020-01-09 10:54:51 Blank
```

MLWIC2 outputs columns with `filename` and the top-5 predictions along with their associated confidence values. Filenames are represented as `camera_location/image_filename`. We will need to create a variable in the human vision data set that has this same format so that we can merge the data sets containing human and computer vision classifications. In the human vision data set, the camera location and filename are contained in different columns, so we combine them using the `unite` function [@R-dplyr]. Before doing so, we  use the `str_replace` function to reformat the `deployment_id` variable so that it matches the format of the MLWIC2 data set. These steps will allow us to later join our human and computer vision data sets using the common variable, `filename`. We also select the columns of interest.


```r
human_vision$deployment_id <- human_vision$deployment_id %>% 
  str_replace(pattern = "-.*", "/")

human_vision <- human_vision %>% 
  unite(filename, c("deployment_id", "filename"), sep = "")

hv <- human_vision %>% 
  group_by(filename, timestamp) %>%
  select(filename, timestamp, common_name) # select columns of interest
```

MLWIC2 provides predictions for species from North America (see list of predicted species here <https://github.com/mikeyEcology/MLWIC2/blob/master/speciesID.csv>). However, you can also use the MLWIC2 `empty_animal` model for  distinguishing blanks from images containing an object. For our example with species from South America, we will use the `species_model` as we want to evaluate model performance for predicting species present both in North and South America. These species include cattle (in MLWIC2 species list "Cow"), armadillos, opossums, horses, humans, dogs, white-tailed deer and mountain lions (i.e., pumas).

Let's inspect the species names in our data set, as we might have to replace some names according to MLWIC2 classes.


```r
unique(human_vision$common_name) %>% 
  sort()
```

```
##  [1] "Alouatta Species"             "Amazonian Motmot"            
##  [3] "Ants"                         "Bird"                        
##  [5] "Black Agouti"                 "Blank"                       
##  [7] "Bos Species"                  "Bush Dog"                    
##  [9] "Caprimulgidae Family"         "Capybara"                    
## [11] "Cervidae Family"              "Collared Peccary"            
## [13] "Common Green Iguana"          "Crab-eating Fox"             
## [15] "Crestless Curassow"           "Dasypus Species"             
## [17] "Domestic Dog"                 "Domestic Horse"              
## [19] "Fasciated Tiger-heron"        "Giant Anteater"              
## [21] "Giant Armadillo"              "Giant Otter"                 
## [23] "Insect"                       "Jaguar"                      
## [25] "Jaguarundi"                   "Lizards and Snakes"          
## [27] "Lowland Tapir"                "Mammal"                      
## [29] "Margarita Island Capuchin"    "Margay"                      
## [31] "Neotropical Otter"            "Northern Amazon Red Squirrel"
## [33] "Ocelot"                       "Ornate Tití Monkey"          
## [35] "Pecari Species"               "Possum Family"               
## [37] "Puma"                         "Red Brocket"                 
## [39] "Rodent"                       "Saimiri Species"             
## [41] "South American Coati"         "Southern Tamandua"           
## [43] "Spix's Guan"                  "Spotted Paca"                
## [45] "Tayra"                        "Turkey Vulture"              
## [47] "Turtle Order"                 "Unknown species"             
## [49] "Weasel Family"                "White-lipped Peccary"        
## [51] "White-tailed Deer"
```

Checking the species list, we can identify the species of interest present in North and South America. To replace species names with names used by MLWIC2, we use the `case_when` function [@R-dplyr] to implement multiple conditional statements, creating a variable, `class`, containing the replaced names; this makes sure that we are using the same species names in both visions. We include a class `Other_hv` for classes identified by human vision that are not identified by MLWIC2 computer vision.


```r
hv <- hv %>% 
  mutate(class = factor(case_when(common_name == "Blank" ~ "Blank",
                              common_name == "Human" |
                                common_name == "Human-Camera Trapper" ~ "Human",
                              common_name == "Bos Species" ~ "Cattle",
                              common_name == "Dasypus Species" ~ "Armadillo",
                              common_name == "Possum Family" ~ "Opossum",
                              common_name == "Domestic Horse" ~ "Horse",
                              common_name == "Domestic Dog" ~ "Dog",
                              common_name == "White-tailed Deer" | 
                                common_name =="Cervidae Family" ~ "White-tailed Deer",
                              common_name == "Puma" ~ "Puma",
                              TRUE ~ "Other_hv"))) %>% 
  
  ungroup()
```

### Format computer vision data set

Let's read the MLWIC2 output, remove unwanted patterns in the filenames using `str_remove` and replace species codes with species names using `case_when`.  We include a class `Other_cv` for classes identified by computer vision that were not identified by human vision. We also use the `factor` and the `levels` function [@R-base] to convert the classification variables into factors with the same levels in both data sets. 

Note that we have moved the model output to the `data/mlwic2` folder from its original location (in the same folder as the `MLWIC2_helper_files` that you previously downloaded).


```r
computer_vision <- read_csv(here("data", "mlwic2", "MLWIC2_output.csv"))

cv <- computer_vision %>%
  mutate(across(c(guess1, guess2, guess3, guess4, guess5),
                ~ case_when(. == 27 ~ "Blank",
                            . == 11 ~ "Human",
                            . == 1 ~ "Cattle",
                            . == 7 ~ "Armadillo",
                            . == 9 ~ "Opossum",
                            . == 10 ~ "Horse",
                            . == 15 ~ "Dog",
                            . == 18 ~ "White-tailed Deer",
                            . == 20 ~ "Puma",
                              TRUE ~ "Other_cv")))

# The code below will remove the path of each picture and other unwanted patterns. 
# It will only leave the location name and filename.
cv$fileName <- cv$fileName %>% 
  str_remove(pattern = "b'/Volumes/ct-data/CH1/jan2020/") %>%
  str_remove(pattern = "'") %>% 
  str_remove(pattern = "detections/")

cv$fileName <- sub("/1.*113", "", cv$fileName)
```

When creating the computer vision label, we will only consider MLWIC2's top guess (i.e., `guess1`).

```r
cv <- cv %>% 
  rename(filename = fileName, class = guess1)

all_levels <- append(levels(factor(cv$class)), 
                     levels(factor(hv$class))) %>% 
  unique() %>% 
  sort()

cv$class <- factor(as.character(cv$class), levels = all_levels)
hv$class <- factor(as.character(hv$class), levels = all_levels)
```


### Merging computer and human vision data sets

Now that we have the same format for both human and computer vision data sets, we can use various "joins" [@R-dplyr] to merge the two data sets together so that we can evaluate the accuracy of MLWIC2. First, however, we will eliminate any images that were not processed by both humans and AI.


```r
# Determine which images have been viewed by both methods
ind1 <- cv$filename %in% hv$filename # in both
ind2 <- hv$filename %in% cv$filename # in both

cv <- cv[ind1,] # eliminate images not processed by human vision
hv <- hv[ind2,] # eliminate images not processed by computer vision

# Number of photos eliminated
sum(ind1 != TRUE) # in computer vision but not in hv
```

```
## [1] 8231
```

```r
sum(ind2 != TRUE) # in human vision but not in cv
```

```
## [1] 766
```


Now, we can use:

- an `inner_join` with `filename` and `class` to determine images that have correct predictions (i.e., images with the same class assigned by computer and human vision)
- an `anti_join` with `filename` and `class` to determine which records in the human vision data set have incorrect predictions from computer vision.
- an `anti_join` with `filename` and `class` to determine which records in the computer vision data set have incorrect predictions. 

We assume the classifications from human vision to be correct and distinguish them from MLWIC2 predictions. The MLWIC2 predictions will be correct if they match a class assigned by human vision for a particular record and incorrect if the classes assigned by the two visions differ.



```r
# correct predictions
matched <- cv %>% 
  inner_join(y = hv, by = c("filename", "class"), suffix = c("_cv", "_hv")) %>%
  mutate(class_hv = class) %>%
  rename(class_cv = class) %>%
  select(filename, confidence1, class_cv, class_hv)

# records in the human vision data set whose predictions are incorrect
hv_only <- hv %>% 
  anti_join(y = cv, by = c("filename", "class"), suffix = c("_hv", "_cv")) %>%
  rename(class_hv = class)

# records in the computer vision data set whose predictions are incorrect
cv_only <- cv %>% 
  anti_join(y = hv, by = c("filename", "class"), suffix = c("_cv", "_hv")) %>%
  rename(class_cv = class)
```

We then use `left_join` to merge the predictions from the `cv_only` (computer vision) data set onto the records from the `hv_only` (human vision) data set.


```r
hv_mismatch <- hv_only %>% 
  left_join(cv_only, by = "filename") %>% 
  select(filename, confidence1, class_cv, class_hv)
```

We then check for any computer vision records that are not yet accounted for in our data sets containing records with correct or incorrect predictions, i.e., `matched` and `hv_mismatch`, respectively.


```r
cv_others <- cv_only[cv_only$filename %in% hv_mismatch$filename != TRUE,]

cv_others
```

```
## # A tibble: 0 × 13
## # … with 13 variables: ...1 <dbl>, filename <chr>, answer <dbl>,
## #   class_cv <fct>, guess2 <chr>, guess3 <chr>, guess4 <chr>, guess5 <chr>,
## #   confidence1 <dbl>, confidence2 <dbl>, confidence3 <dbl>, confidence4 <dbl>,
## #   confidence5 <dbl>
```

Finally, we select only the variables we need, and combine the matched and mismatched data sets. Additionally, we remove the "Human" class from the data set; human images in this data set predominately correspond to images taken during camera setup. 


```r
matched <- matched %>% 
  select(filename, confidence1, class_cv, class_hv)
hv_mismatch <- hv_mismatch %>% 
  select(filename, confidence1, class_cv, class_hv)

both_visions <- rbind(matched, hv_mismatch)

both_visions <- both_visions %>% 
  filter(class_cv != "Human" & class_hv != "Human")
```

### Summarizing human and computer vision records by class

Next, we count the number of records of each class separately for human and computer vision. We will group the data by `class` and then count the number of observations using `n()` inside the `summarise` function. Then, we use the `left_join` function to join the class counts in computer and human vision using the `class` to match observations in the two data sets. Lastly, we add a suffix to the `class` variable to distinguish the counts of human and computer vision. Table \@ref(tab:myDThtmltools3) contains the class counts for the two visions.


```r
sp_counts_cv <- both_visions %>% 
  group_by(class_cv) %>% 
  summarise(n = n()) %>% 
  rename(class = class_cv)
        
sp_counts_hv <- both_visions %>% 
  group_by(class_hv) %>% 
  summarise(n = n()) %>% 
  rename(class = class_hv)

sp_counts <- full_join(x = sp_counts_cv, y = sp_counts_hv, 
                       by = "class", 
                       suffix = c("_cv", "_hv")) %>% 
  arrange(class)
```



```{=html}
<div id="htmlwidget-98cd99f33ae774200887" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-98cd99f33ae774200887">{"x":{"filter":"none","vertical":false,"data":[["1","2","3","4","5","6","7","8","9","10"],["Armadillo","Blank","Cattle","Dog","Horse","Opossum","Other_cv","Other_hv","Puma","White-tailed Deer"],[2,7554,278,53,5,254,90918,null,43,523],[5707,19658,3031,18,806,936,null,68109,119,1246]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>class<\/th>\n      <th>n_cv<\/th>\n      <th>n_hv<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[2,3]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script>
```
<table>
<caption>(#tab:myDThtmltools3)Counts of images classified by MLWIC2 (n_cv) and humans (n_hv) for each class in the data set.</caption>
</table>

### Confusion matrix and performance measures

Finally, we can proceed with estimating a confusion matrix and various AI performance measures using the `confusionMatrix` function from the `caret` package [@R-caret] and specifying a 0.65 confidence threshold to accept MLWIC2 predictions. We can then plot the confusion matrix using `ggplot2` [@R-ggplot2]. The `confusionMatrix` function requires a data argument for predicted classes and a reference for true classifications, both as factor classes and with the same factor levels. We include  `mode="prec_recall"` when calling the `confusionMatrix` function [@R-caret] to estimate precision and recall.


```r
library(caret) # to inspect model performance
library(ggplot2)

# Estimate confusion matrix
both_visions_0.65 <- both_visions
both_visions_0.65$class_cv[both_visions_0.65$confidence1 < 0.65] <- "Blank" 
cm_mlwic2_0.65 <- confusionMatrix(data = both_visions_0.65$class_cv, 
                      reference = (both_visions_0.65$class_hv), 
                      mode = "prec_recall")

# Plot confusion matrix
plot_cm_mlwic2_0.65 <- cm_mlwic2_0.65 %>% 
  pluck("table") %>% 
  as.data.frame() %>% 
  rename(Frequency = Freq) %>% 
  ggplot(aes(y=Prediction, x=Reference, fill=Frequency)) + 
  geom_raster() +
  scale_fill_gradient(low = "#D6EAF8",high = "#2E86C1") +
  geom_text(aes(label = Frequency), size = 2.5) +# size for matrix counts
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90), # define angle for x axis text)
        legend.text = element_text(size = 6),
        legend.key.width = unit(1, "cm"))

plot_cm_mlwic2_0.65
```

<div class="figure">
<img src="04-mlwic2_files/figure-html/confmatrix-MLWIC2-1.png" alt="Confusion matrix applied to classifictions from MLWIC2 using a confidence threshold of 0.65." width="672" />
<p class="caption">(\#fig:confmatrix-MLWIC2)Confusion matrix applied to classifictions from MLWIC2 using a confidence threshold of 0.65.</p>
</div>

Now we can use the confusion matrix to estimate metrics of model performance including accuracy, precision, recall and F-1 score (See Chapter [1][Introduction] for metrics description).


```r
(overall_accuracy <- cm_mlwic2_0.65 %>% 
  pluck("overall", "Accuracy") %>% 
  round(., 2))
```

```
## [1] 0.11
```

```r
classes_metrics_mlwic2_0.65 <- cm_mlwic2_0.65 %>% 
  pluck("byClass") %>%
  as.data.frame() %>% 
  select(Precision, Recall, F1) %>% 
  rownames_to_column() %>% 
  rename(class = rowname) %>% 
  mutate(across(is.numeric, ~round(., 2))) %>% 
  filter(!is.na(Precision | Recall))

classes_metrics_mlwic2_0.65$class <- str_remove(string = classes_metrics_mlwic2_0.65$class, 
                                                pattern = "Class: ")
```


```{=html}
<div id="htmlwidget-9816dcb9dc8068108297" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-9816dcb9dc8068108297">{"x":{"filter":"none","vertical":false,"data":[["1","2","3","4","5","6"],["Blank","Cattle","Dog","Opossum","Puma","White-tailed Deer"],[0.24,0.76,0,0.33,0.8,0.3],[0.53,0.03,0,0.03,0.03,0.05],[0.33,0.06,null,0.06,0.06,0.09]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>class<\/th>\n      <th>Precision<\/th>\n      <th>Recall<\/th>\n      <th>F1<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"columnDefs":[{"className":"dt-right","targets":[2,3,4]},{"orderable":false,"targets":0}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script>
```
<table>
<caption>(#tab:myDThtmltools2)Model performance metrics for each class in the data set using a 0.65 confidence threshold.</caption>
</table>

We see that the model has the highest precision values for the "puma" (80% precision at 3% recall) and  "cattle" (76% precision at 3% recall) classes. The "Blank" class has the highest recall value of 53% at a 24% precision. We can inspect how model performance changes if we select a different confidence threshold than 0.65, as we demonstrate in the next section.
 

### Confidence thresholds

Lets begin by looking at the distribution of confidence values associated with each MLWIC2 classification using the `geom_bar` function [@R-ggplot2]. We first identify the species that have at least 30 records for both classification methods (human and computer vision).


```r
sp_plots <- sp_counts %>% 
  filter(n_cv > 30 & n_hv > 30)

both_visions_sp <- both_visions %>% 
  filter(class_cv %in% sp_plots$class) %>% 
  rename(Species = class_cv)

# Plot confidence values 
both_visions_sp %>% 
  ggplot(aes(confidence1, group = Species, colour = Species)) +
  geom_bar() + 
  facet_wrap(~Species, scales = "free") +
  labs(y = "Empirical distribution", x = "Confidence values") +
  theme(legend.position = "bottom") +
  scale_color_viridis_d()
```

<div class="figure">
<img src="04-mlwic2_files/figure-html/unnamed-chunk-15-1.png" alt="Distribution of confidence values associated with classes predicted by MLWIC2." width="864" />
<p class="caption">(\#fig:unnamed-chunk-15)Distribution of confidence values associated with classes predicted by MLWIC2.</p>
</div>


Most of the classes (e.g., "cattle", "opossum", "puma" and "white-tailed deer") have a uniform distribution with records distributed along the full range of confidence values. The "Blank" class has a bell-shaped distribution, with most of the records associated with medium confidence values.

To inspect how precision and recall change when different confidence thresholds are established for assigning a class predicted by computer vision, we define a function that will calculate these metrics for a user-defined confidence threshold. This function will assign a “Blank” label whenever the confidence for a computer vision prediction is below a particular confidence threshold. Higher thresholds should reduce the number of false positives but at the expense of more false negatives. We then estimate the same performance metrics for the specified confidence threshold. By repeating this process for several different thresholds, users can evaluate how precision and recall change with the confidence threshold and choose a threshold that balances these two performance metrics.


```r
threshold_for_metrics <- function(conf_threshold = 0.7) {
  tmp <- both_visions
  tmp$class_cv[tmp$confidence1 < conf_threshold] <- "Blank" 
  # assign a "Blank" class whenever the confidence value
  # of a prediction is lower than the threshold provided as 
  # an argument in the function
  cm <- confusionMatrix(data = tmp$class_cv, 
                        reference = tmp$class_hv, 
                        mode = "prec_recall") 
  # use the confusionMatrix function from the caret package using the
  # class_cv containing the new labels according to a particular
  # confidence threshold
  classes_metrics <- cm %>% # get confusion matrix
    pluck("byClass") %>% # get metrics by class
    as.data.frame() %>% # assign a data frame object
    select(Precision, Recall, F1) %>% # select metrics of interest
    rownames_to_column() %>% # format data frame
    rename(class = rowname) %>% # rename class column
    mutate(conf_threshold = conf_threshold)
  classes_metrics$class <- str_remove(string = classes_metrics$class,
                                        pattern = "Class: ") 

    return(classes_metrics) # return a data frame with metrics for every class
}
```

Let's estimate model performance metrics for confidence values ranging from 0.1 to 0.99 using the map_df function [@purrr] . The map_df function [@purrr] returns a data frame object. Once we get a dataframe of model performance metrics for a range of confidence values, we can plot the results using the `ggplot2` package [@R-ggplot2].


```r
conf_vector = seq(0.1, 0.99, length=100)

metrics_all_confs <- map_df(conf_vector, threshold_for_metrics)
```


```r
metrics_all_confs <- metrics_all_confs %>% 
  mutate_if(is.numeric, round, digits = 2)

prec_rec_mlwic2 <- metrics_all_confs %>% 
  filter(class %in% sp_plots$class) %>%
  rename(Class = class, Confidence_threshold = conf_threshold) %>% 
  ggplot(aes(x = Recall, y = Precision, group = Class, colour = Class)) +
  geom_point(aes(size = Confidence_threshold)) +
  scale_size(range = c(0.1,3)) +
  labs(x = "Recall", y = "Precision", ) +
  scale_color_viridis_d() +
  geom_line()

prec_rec_mlwic2
```

<div class="figure">
<img src="04-mlwic2_files/figure-html/mlwic2-thresholds-1.png" alt="Precision and recall for different confidence thresholds for classes predicted by MLWIC2." width="100%" />
<p class="caption">(\#fig:mlwic2-thresholds)Precision and recall for different confidence thresholds for classes predicted by MLWIC2.</p>
</div>



We see that as we increase the confidence threshold, precision associated with the different species labels usually increases and recall decreases (Figure \@ref(fig:mlwic2-thresholds)); the opposite pattern occurs for the "Blank" class. Ideally, we would like AI to have high precision and recall, though the latter is likely to be more important in most cases. Remember that precision tells us the probability that the class is truly present when AI identifies the  class as being present in an image (Chapter [1][Introduction]). If AI suffers from low precision, then we may have to manually review photos that AI tags as having a class present in order to remove false positives.  Recall, on the other hand, tells us how likely AI is to find a class in the image when it is truly present.  If AI suffers from low recall, then it will miss many photos containing a class that is truly present. To remedy this problem, we would need to review images where AI says the class is absent in order to reduce false negatives. To compare confusion matrices estimated using different confidence thresholds please refer to Chapter [4][MegaDetector - Microsoft AI].


## Model training

For training a model, we also need to provide a CSV file containing image filenames. For illustration, we will get the filenames from a small set of images included in the repository (`images/train` folder), but you will want to train a model with at least 1,000 labeled images per species [@schneider_2020]. To get the filenames for those images we can use the `make_input` function (See Section \@ref(format-mlwic2)); in the argument `path_prefix` you should provide the path of the directory containing the images. The `make_input` function will create the `image_labels.csv` file in the directory provided in the `output_dir` argument. We rename this file as `images_names_train_temp.csv`. 


```r
# this will read filenames from each image and create a CSV file with them
make_input(path_prefix = here("data","mlwic2","images", "train"),
           option = 4,
           find_file_names = TRUE,
           output_dir = here("data", "mlwic2", "training")) 
```

```
## Your file is located at '/Users/julianavelez/Documents/GitHub/Processing-Camera-Trap-Data-using-AI/data/mlwic2/training/image_labels.csv'.
```

```r
file.rename(from = "data/mlwic2/training/image_labels.csv", 
            to = "data/mlwic2/training/images_names_train_temp.csv")
```

```
## [1] TRUE
```

Once we have the filenames for the training set, we add the corresponding human vision labels for each image using a `left_join`. Additionally, we recode our species names with numbers as required by the MLWIC2 package; these numbers must be consecutive and should start with `0` [@tabak_2020]. We save this file `images_names_train.csv` with recoded species names using the `write_csv` function.


```r
img_labs <- read_csv(here("data", "mlwic2", "training", "images_names_train_temp.csv"), 
                     col_names = c("filename", "class"))

hv_train <- read_csv(here("data", "mlwic2", "training", "images_hv.csv"))

imgs_train <- img_labs %>% 
  left_join(hv_train, by = "filename") %>% 
  select(filename, common_name) %>% 
  mutate(class_ID = factor(case_when(common_name == "Blank" ~ 1,
                                     common_name == "Black Agouti" ~ 2,
                                     common_name == "Bos Species" ~ 3,
                                     common_name == "Cervidae Family" |
                                       common_name ==  "White-tailed Deer" ~ 4,
                                     common_name == "Collared Peccary" ~ 5,
                                     common_name == "Dasypus Species" ~ 6,
                                     common_name == "Domestic Dog" ~ 7,
                                     common_name == "Domestic Horse" ~ 8,
                                     common_name == "Giant Anteater" ~ 9,
                                     common_name == "Giant Armadillo" ~ 10,
                                     common_name == "Human" |
                                       common_name == "Human-Camera Trapper" ~ 11,
                                     common_name == "Jaguar" ~ 12,
                                     common_name == "Lowland Tapir" ~ 13,
                                     common_name == "Nine-banded Armadillo" ~ 14,
                                     common_name == "Ocelot" ~ 15,
                                     common_name == "Possum Family" ~ 16,
                                     common_name == "Puma" ~ 17,
                                     common_name == "South American Coati" ~ 18,
                                     common_name == "Southern Tamandua" ~ 19,
                                     common_name == "Spotted Paca" ~ 20,
                                     common_name == "White-lipped Peccary" ~ 21,
                                       TRUE ~ 0))) %>%
  ungroup() %>% 
  select(filename, class_ID)
  
write_csv(imgs_train, file = "data/mlwic2/training/images_names_train.csv", col_names = FALSE)
```

We then use the `train` function  to train a new model, where we need to specify arguments that were also used with the `classify` function (see Section \@ref(mlwic2-ai-module)); these include the `path_prefix`, `model_dir`, `python_loc`, `os` and `num_cores`. In the `data_info` argument we pass the `images_names_train.csv` file. We also need to specify the number of classes that we want to train the model to predict (e.g., these classes might differ from the 58 classes predicted when using MLWIC2's built-in AI species model).

We can use `retrain = FALSE`  to train a model from scratch or `retrain = TRUE` if we want to retrain a pre-specified model using *transfer learning*.^[Transfer learning is a process in which a source model and new data set are used to improve model learning for a new task.] For more references on model training see <https://github.com/mikeyEcology/MLWIC2>.

We also need to specify the number of epochs (i.e., the number of times the learning algorithm will iterate on the training data set) using the`num_epochs` argument; we use the recommended default of 55 [@tabak_2020]. Lastly, we specify the directory where we want to store the model using the  `log_dir_train` argument; we use "SA" for "South America".


```r
train(path_prefix = here("data","mlwic2", "images", "train"),
         data_info = here("data", "mlwic2", "training", "images_names_train.csv"), # absolute path to the make_input output
         model_dir = here("data","mlwic2", "MLWIC2_helper_files/"),
         python_loc = "/Users/julianavelez/opt/anaconda3/envs/ecology/bin/", # absolute path of Python on your computer
         os = "Mac", # specify your operating system; "Windows" or "Mac"
         num_cores = 3,
      num_classes = 22, # number of classes in your data set 
      retrain = FALSE,
      num_epochs = 55, # initially you can use a smaller number for num_epochs to verify model training; it will take a long time to run.
      log_dir_train ="SA"
      )
```

## Classify using a trained model {#classify-trained}

Then you can run the model that you trained using a test image set. You should also get filenames for these images (renamed as `images_names_test.csv`) and pass it when running the model with the `classify` function.


```r
make_input(path_prefix = here("data", "mlwic2", "images", "test"),
           option = 4,
           find_file_names = TRUE,
           output_dir = here("data","mlwic2","training"))
```

```
## Your file is located at '/Users/julianavelez/Documents/GitHub/Processing-Camera-Trap-Data-using-AI/data/mlwic2/training/image_labels.csv'.
```

```r
file.rename(from = "data/mlwic2/training/image_labels.csv", to = "data/mlwic2/training/images_names_test.csv")
```

```
## [1] TRUE
```



```r
classify(path_prefix = here("data", "mlwic2", "images", "test"), # absolute path to test images directory
         data_info = here("data", "mlwic2", "training", "images_names_test.csv"), # absolute path to your image_labels.csv file
         model_dir = here("data", "mlwic2", "MLWIC2_helper_files"),
         log_dir = "SA", # model name
         python_loc = "/Users/julianavelez/opt/anaconda3/envs/ecology/bin/", # absolute path of Python on your computer
         os = "Mac", # specify your operating system; "Windows" or "Mac"
         make_output = TRUE,
         num_cores = 3,
         output_name = "output_SA.csv", # name for model output
         num_classes = 22
         )
```

Finally, you can read the trained model output to see how it looks like. It contains a column with the human vision label, `answer`, and top-5 predictions for each image with their associated confidence values. Once you have this output, you can verify model performance as described along Section \@ref(ai-mlwic2).


```r
output_trained <- read_csv(here("data", "mlwic2", "MLWIC2_helper_files", "output_SA.csv"))
```

## Conclusion

We have seen how to set-up MLWIC2, prepare the required input files, and run its built-in AI model. Additionally, we illustrated how one can evaluate MLWIC2 performance by comparing true classifications with computer predictions, for species or groups found in North and South America (e.g., "Blank", "cattle","armadillo", "opossum", "horse", "dog", "white-tailed deer" and "puma"). For our data set, MLWIC2 classifications had low precision and recall, probably due to strong differences between the training and the test data. Thus, we would need to train our own models using the tools provided by the MLWIC2 package to improve model performance with our data.

