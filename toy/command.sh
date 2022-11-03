filename=toy.txt
join -t $'\t' \
    <(tr $'\t' $'\n' < toy_schema.txt |
      cat -n |
      sort -k 1,1) \
    <(join -t $'\t' \
        <(join -t $'\t' \
            <(cat -n "$filename" |
              cut -f 1,7 |
              grep -e $'\tgamma' |
              sort -k 1,1) \
            <(cat -n "$filename" |
              cut -f 1,6 |
              grep -e $'\tbaz' |
              sort -k 1,1) |
            cut -f 1) \
        <(cat -n "$filename" | sort -k 1,1) |
      cut -f 2- |
      head -n1 |
      tr $'\t' $'\n' |
      cat -n |
      sort) |
  sort -n
