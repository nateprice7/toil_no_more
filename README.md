# Toil No More: Efficiently working with Big Data

## Table of Contents

* [Lab Overview](#lab-overview)
* [Lesson 1 - Intro to Using The Shell to Parse Data](#lesson-1---getting-started)
* [Lesson 2 - Using Github From The CLI](#lesson-2---introduction-to-github-cli)
* [Appendix](#appendix)

## Lab Overview
Systems that work with large datasets can generate a lot of work that would qualify as [toil](https://sre.google/sre-book/eliminating-toil/).
This lab is intended to help you develop some skills that can be helpful in working efficiently with these systems.

### Prerequisites
* Command Line Shell (Preferable bash or zsh)
* Git Hub CLI Tools

## Lesson 1 - Getting Started

### Objective

1. Learn how to slice and dice data from the CLI (command line interface)
2. Apply your skills to answer questions on a larger dataset

### Example DataSet
Introduce the dataset and the problem

#### Exercise 1.1 Getting Data From Individual Columns
filter one colums

filter the second column

#### Exercise 1.3 Search on a Combination of Columns
search two at once

#### Exercise 1.4 Tidying up
make the sesults look pretty

#### Exercise 1.5 Applying What You Have Learned to a Bigger Dataset
Now that you have gotten a feel for how to do some data investigation on the command line we are going to apply those same skills to a more realistic dataset. In the data folder we have a data feed from a test dataset from Adobe Analytics. This is web site tracking data for a fictional retailer.

For this excercise we believe that there are some rows is the dataset where both the x field is set to "" and the y field is set to "". This combination of values shouldn't be possible so we want to see the entire rows so that we can determine what is going on.  

## Lesson 2 - Introduction to Github CLI

CLI access is common for a number of systems that you may want to work with.
This lesson gives an example using the github CLI of the types of automations that can
be done with this type of CLI access.

#### Exercise 2.1 Getting The github CLI working

The first step is to get the github cli installed on your machine. The [following] page has directions for a number of operating systems. 
After you have the github cli installed run `gh auth login` to authenticate with your GitHub account.

Once the authentication is complete run the following command to test it out by getting a list of PRs. 

`gh pr list -R nateprice7/toil_no_more`

#### Exercise 2.2 Working With PRs
Reviewing PRs can be an important part of ensuring code quality in a product. Sometimes you may start a review and leave some comments in a pending state and not have time to finsih the review. If the list of PRs adds up and a little time passes then it can at times be pretty tedious. We are going to build up a command that will quickly tell us which reviews need to be finished.

As we tried in the step above we can get a list of the PRs with the following command.
gh pr list -R nateprice7/toil_no_more


gh pr list -R nateprice7/toil_no_more --json=number,reviews | jq ".[]| select(.reviews[]|.author.login == \"$USER\" and .state == \"PENDING\")|.number

#### Exercise 2.2 Extending your knowledge
give a problem where they can apply their skills.

## Appendix
* [Google SRE Handbook](https://sre.google/sre-book/eliminating-toil/)
