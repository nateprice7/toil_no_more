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
Introduce teh dataset and the problem

#### Exercise 1.1 Getting Data From Individual Columns
filter one colums

filter the second column

#### Exercise 1.3 Search on a Combination of Columns
search two at once

#### Exercise 1.4 Tidying up
make the sesults look pretty

#### Exercise 1.5 Applying What You Have Learned to a Bigger Dataset
introduce the bigger dataset
introduce the problem



## Lesson 2 - Introduction to Github CLI

CLI access is common for a number of systems that you may want to work with.
This gives an example using the github CLI of the types of automations that can
be done with this type of CLI access.

#### Exercise 2.1 Getting The github CLI working
basic information on how to get started and authentication

#### Exercise 2.2 Working With PRs
Introduce example of wanting a list of partially reviewed PRs.
gh pr list -R nateprice7/toil_no_more --json=number,reviews | jq ".[]| select(.reviews[]|.author.login == \"$USER\" and .state == \"PENDING\")|.number

#### Exercise 2.2 Extending your knowledge
give a problem where they can apply their skills.

## Appendix
* [Google SRE Handbook](https://sre.google/sre-book/eliminating-toil/)
