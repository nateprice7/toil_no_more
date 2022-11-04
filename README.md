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
This workshop will walk through how to use basic Unix text-processing commands to filter through data stored in a typical tab-delimited text file.

### Objective

1. Learn how to slice and dice data from the CLI (command line interface)
2. Apply your skills to answer questions on a larger dataset

### Example DataSet

We will walk through finding a record in a tab-delimited text file using a simple toy-problem text file first.
This toy problem can be found in the "toy/" subdirectory of this repo.  The data is in "toy.txt" and a list of column names is in "toy\_schema.txt".

### Procedure

First, let's look at the column names found in "toy\_schema.txt".
To do this, we can use the `cat` command.
`cat` is an abbreviation of "concatenate" and can be used to output multiple files together by listing several file names as input parameters.
However, it is also often used to simply print out the contents of a single file:

    cat toy_schema.txt

The field names are listed in a single line, separated by tab characters.
However, it can be more convenient to see each column name on its own line.
To do that, we can use the `tr` command (short for "transform"):

    tr $'\t' $'\n' < toy_schema.txt

Here, we've asked `tr` to replace every tab character with a new-line character.
(The dollar-quote syntax `$'\t'` is interpreted by the shell, and is a convenient way of putting special characters such as tab and newline in shell commands.)

`cat` has an extra option that we will be making heavy use of in the remainder of this workshop.
By passing the `-n` flag to cat, it will number each line of output, so we can easily refer to lines by number.
If we don't give `cat` a file name to print, it will instead read from its input and print it out directly.
We can take advantage of this behavior in a pipeline to number the lines produced by another command (in this case, `tr`):

    tr $'\t' $'\n' < toy_schema.txt | cat -n

From this command, we can see that column 5 is named "attr1" and column 6 is named "attr2".

Now we can look at the contents of the file "toy.txt":

    cat toy.txt

Our objective for this workshop will be to find a record in "toy.txt" that has "baz" for `attr1` and "gamma" for `attr2`.

To start with, we remember that `attr1` is column 5 and `attr2` is column 6.
Because we will usually be adding line numbers to each file we work with, that will add an extra column on the beginning, so we will generally be referring to columns 6 and 7 (originally 5 and 6).
Let's look at the values for `attr1` and the row numbers they occur on by using a new text command, `cut`.
The `cut` command allows us to keep only specific columns from a text table.
We use the `-f` flag to pick which columns to keep:

    cat -n toy.txt | cut -f 1,6

This command shows us the value for `attr1` on every row of the table.
We can use another text processing command, `grep`, to filter out rows we don't care about.
The `grep` command is a powerful pattern matching tool that we can use to do sophisticated filtering, but this time we're just looking for lines with a specific string, the string "baz", preceded by a tab, at the end of the line.
(In `grep`, a dollar sign matches the end of the line.)

    cat -n toy.txt | cut -f 1,6 | grep -e $'\tbaz$'

Now we see the five rows that have "baz" for `attr1`.
We can do the same thing to find "gamma" in `attr2`:

    cat -n toy.txt | cut -f 1,7 | grep -e $'\tgamma$'

Next we'll use a command called `join` to combine the results from the two columns.
We can give `join` two files and it will print the lines combined from each file where the join key matches between the two rows.
By default, `join` uses the first column as the join key, although this can be controlled with command-line flags.
If you want to use `join` to join rows on a column other than the first column, you can look up the flags needed in the man page by typing `man join` in the shell.
For us, joining on the first column works well, so we will leave this default alone.
However, `join` does require that the two files being joined are both sorted on the join key.
In our case they are sorted, but they are numerically sorted, and we need them lexicographically sorted, so we will pipe the results of the previous column-filtering commands through `sort` to make sure they're properly ordered.
I will also showcase how you can use a shell's history expansion feature to reuse previous commands run in the shell when crafting a new command.
In most interactive shells, when you use an exclamation point (`!`), it will expect to do history expansion.
If you follow the exclamation point with a negative integer, the shell will replace the text of the corresponding command backward in the history into the command you're crafting now.
Two exclamation points (`!!`) is equivalent to `!-1` and will just substitute in the most recent command.
If you have history expansion disabled or have lost track of the count of the recent command you want to substitute in, you can often just use your mouse in a graphical terminal to copy-and-paste the command you want into the new command.
In the instructions below where I use history expansion to show how to expand a previous command to accomplish the next step, I will also show the resulting command after the substitution has been performed (with some white space reformatting for readability).

The `join` command we want will take the intersection of the rows found in the matches for `attr1` and `attr2`.
We sort the output of each of those commands and then pass them to `join` so it will only print the rows that match in both columns (in this case there is only one such matching row):

    join -t $'\t' <(!-1 | sort -k1,1) <(!-2 | sort -k1,1)

Here is the command with the history substitution expanded:

    join -t $'\t' \
            <(cat -n toy.txt |
                cut -f 1,7 |
                grep -e $'\tgamma$' |
                sort -k1,1) \
            <(cat -n toy.txt |
                cut -f 1,6 |
                grep -e $'\tbaz$' |
                sort -k1,1)

The command above not only introduced our first use of `join`, but it also used some new shell syntax.
In many modern shells, when you execute a command with a less-than sign followed by another command in parentheses (`<( ... )`), the shell executes the command inside the parentheses and makes the output of that command available as a file to the outer command being typed.
You can think of it as the shell creating a temporary file with the output of the inner command stored in it and passing the name of the temporary file to the outer command.
(The actual details of how this works are more complicated, but this simplified model is close enough for a working understanding.)

From the above `join` command, we saw the output `7 gamma baz`.  This tells us that row 7 had our desired values of "baz" and "gamma" for `attr1` and `attr2`.
This is close to what we want, but we actually want to see the entire record rather than just the row number and the columns we already knew.
Since we have the row number, we could just open the file in an editor and jump to the given text row.
But often large files of data are unwieldy in a text editor.
Let's try to use the text-processing commands we already know to print the row we want in the terminal.
To start with, we can use `cut` to throw away everything but the row number:

    !! | cut -f 1

With the history substitution already performed, the command looks like this:

    join -t $'\t' \
            <(cat -n toy.txt |
                cut -f 1,7 |
                grep -e $'\tgamma$' |
                sort -k1,1) \
            <(cat -n toy.txt |
                cut -f 1,6 |
                grep -e $'\tbaz$' |
                sort -k1,1) |
        cut -f 1

Next, we can join this line number with the original file (after numbering and sorting it):

    join -t $'\t' <(!!) <(cat -n toy.txt | sort -k 1,1)

The fully expanded command:

    join -t $'\t' \
            <(join -t $'\t' \
                    <(cat -n toy.txt |
                        cut -f 1,7 |
                        grep -e $'\tgamma$' |
                        sort -k1,1) \
                    <(cat -n toy.txt |
                        cut -f 1,6 |
                        grep -e $'\tbaz$' |
                        sort -k1,1) |
                cut -f 1) \
            <(cat -n toy.txt |
                sort -k 1,1)

In this case we only get one row back that matched our search criteria.
If more than one row comes back, we can use combinations of the commands `head` and `tail` to whittle the result down to just the first row, last row, or some row in the middle.
We also want to get rid of the line number to just get the original record back.
(`cut -f 2-` will do this by keeping all fields but the first.)
Then we can change all the tabs into newlines so we can see the record vertically, and number the fields for reference:

    !! | cut -f 2- | head -n1 | tr $'\t' $'\n' | cat -n

Which expands to:

    join -t $'\t' \
            <(join -t $'\t' \
                    <(cat -n toy.txt |
                        cut -f 1,7 |
                        grep -e $'\tgamma$' |
                        sort -k1,1) \
                    <(cat -n toy.txt |
                        cut -f 1,6 |
                        grep -e $'\tbaz$' |
                        sort -k1,1) |
                cut -f 1) \
            <(cat -n toy.txt |
                sort -k 1,1) |
        cut -f 2- |
        head -n1 |
        tr $'\t' $'\n' |
        cat -n

Finally, we can join the numbered record with the numbered schema we printed out from the beginning of this exercise, so that we can see each column value labeled by its column name and indexed by the column number:

    join -t $'\t' <(tr $'\t' $'\n' < toy_schema.txt | cat -n | sort -k 1,1) <(!! | sort -k 1,1) | sort -n

With the history expanded, this is:

    join -t $'\t' \
            <(tr $'\t' $'\n' < toy_schema.txt |
                cat -n |
                sort -k 1,1) \
            <(join -t $'\t' \
                    <(join -t $'\t' \
                            <(cat -n toy.txt |
                                cut -f 1,7 |
                                grep -e $'\tgamma$' |
                                sort -k1,1) \
                            <(cat -n toy.txt |
                                cut -f 1,6 |
                                grep -e $'\tbaz$' |
                                sort -k1,1) |
                        cut -f 1) \
                    <(cat -n toy.txt |
                        sort -k 1,1) |
                cut -f 2- |
                head -n1 |
                tr $'\t' $'\n' |
                cat -n |
                sort -k 1,1) |
        sort -n

The final `sort -n` is to output the columns in their original order (as opposed to lexicographically ordered by column number as a string of digits).

The command we just finished writing gives us the entire, labeled row we were looking for with `attr1="baz"` and `attr2="gamma"`.
There is one refinement we can do to make it serve us better.
We inserted the name of the file we're looking at, "toy.txt", three times in this command, which is fine if we are only interested in this specific file.
But often, after crafting a command like this for one file, we want to run it again on a different file.
So let's save that file name in a shell variable so that if we change which file we're looking at, we only have to change the command in one place:

    filename=toy.txt ; join -t $'\t' \
            <(tr $'\t' $'\n' < toy_schema.txt |
                cat -n |
                sort -k 1,1) \
            <(join -t $'\t' \
                    <(join -t $'\t' \
                            <(cat -n "$filename" |
                                cut -f 1,7 |
                                grep -e $'\tgamma$' |
                                sort -k1,1) \
                            <(cat -n "$filename" |
                                cut -f 1,6 |
                                grep -e $'\tbaz$' |
                                sort -k1,1) |
                        cut -f 1) \
                    <(cat -n "$filename" |
                        sort -k 1,1) |
                cut -f 2- |
                head -n1 |
                tr $'\t' $'\n' |
                cat -n |
                sort -k 1,1) |
        sort -n

### Exercise: Applying What You Have Learned to a Bigger Dataset

Now that you have gotten a feel for how to do some data investigation on the command line we are going to apply those same skills to a more realistic dataset. In the data folder we have a data feed from a test dataset from Adobe Analytics. This is web site tracking data for a fictional retailer.

For this exercise we believe that there are some rows in the file "data/01-outrainjj04\_20221102-130000.tsv" (whose column names are given in "column\_headers.tsv") where both the `campaign` field is set to "soc:100" and the `country` field is set to "304".
Can you print out this row of data and find what value is in the `zip` field?
You can answer this question by going through the above procedure again, but using these new files as your inputs, and building up the new command piece by piece.
You can also figure out what changes need to be made to the final command to act on the new files, columns, and values, and print the record this way.


## Lesson 2 - Introduction to Github CLI

CLI access is common for a number of systems that you may want to work with.
This lesson gives an example using the github CLI of the types of automations that can
be done with this type of CLI access.

#### Exercise 2.1 Getting The github CLI working

The first step is to get the github cli installed on your machine. The [following](https://cli.github.com/manual/installation) page has directions for a number of operating systems. 
After you have the github cli installed run `gh auth login` to authenticate with your GitHub account.

Once the authentication is complete run the following command to test it out by getting a list of PRs. 

`gh pr list -R nateprice7/toil_no_more`

The last step for setting up this excersize is to go to the pull requests tab on this repo and add one comment to one of the PRs and click "Start a Review". This will add a pending comment on that review that will be used in the next step.

#### Exercise 2.2 Working With PRs
Reviewing PRs can be an important part of ensuring code quality in a product. Sometimes you may start a review and leave some comments in a pending state and not have time to finsih the review. If the list of PRs adds up and a little time passes then it can at times be pretty tedious. We are going to build up a command that will quickly tell us which reviews need to be finished.

As we tried in the step above we can get a list of the PRs with the following command.

`gh pr list -R nateprice7/toil_no_more`

The above list of PRs is nice, but we are interested in the records that have pending reviews. The following command will return the results in a json format and will include the informations about reviews.

`gh pr list -R nateprice7/toil_no_more --json=number,reviews`

If you added a pending comment in the startup step your results will look something like this.

```
[
  {
    "number": 6,
    "reviews": []
  },
  {
    "number": 5,
    "reviews": []
  },
  {
    "number": 4,
    "reviews": []
  },
  {
    "number": 3,
    "reviews": []
  },
  {
    "number": 2,
    "reviews": []
  },
  {
    "number": 1,
    "reviews": [
      {
        "author": {
          "login": "nateprice7"
        },
        "authorAssociation": "OWNER",
        "body": "",
        "submittedAt": null,
        "includesCreatedEdit": false,
        "reactionGroups": [],
        "state": "PENDING"
      }
    ]
  }
]
```

We want to get a list of just the items that have a review for you in the `PENDING` state.

First we need a tool to filter the json output from the command line and `jq` is a great tool for the job. 
The following command will get us the anser that we are looking for and we will follow up with a breakdown of what it does.

`gh pr list -R nateprice7/toil_no_more --json=number,reviews | jq ".[]| select(.reviews[]|.author.login == \"<your username>\" and .state == \"PENDING\")|.number`

`.[]` selects the content inthe top level array

`| select...` filters to items that have you as the author and are in the pending state

`|.number` tells it to just return the number attribute(id of the PR) as the result

Once that is done you can type the following to learn more about that PR.

`gh pr view -R nateprice7/toil_no_more <ID of PR>`

#### Exercise 2.2 Extending your knowledge

Now that you have some experience with the github API see if you can find all of the PRs that are labeled as "good first issues".


## Appendix

* [Workshop Survey](https://forms.office.com/r/D3hwbAPMrsbbbb)
* [Google SRE Handbook](https://sre.google/sre-book/eliminating-toil/)
