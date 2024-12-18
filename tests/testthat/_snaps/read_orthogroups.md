# import produces correct snapshot

    Code
      read_orthogroups(test_path("fixtures", "Orthogroups.tsv"))
    Message
      Orthogroups.tsv contains 11 orthogroups across 5 genomes
    Output
      # A tibble: 11 x 6
         Orthogroup Alcanivorax_sp_EA2 Algoriphagus_sp_ARW1R1 Arenibacter_sp_ARW7G5Y1
         <chr>                   <int>                  <int>                   <int>
       1 OG0000000                  53                     22                      29
       2 OG0000001                  27                     22                      36
       3 OG0000002                  23                     23                      21
       4 OG0000003                  29                     13                      13
       5 OG0000004                   7                      3                       4
       6 OG0000005                   0                      6                       5
       7 OG0000006                   0                      0                       2
       8 OG0000007                  13                     18                      43
       9 OG0000008                  23                      3                       5
      10 OG0000009                   1                      1                       1
      11 OG0000010                   1                      1                       1
      # i 2 more variables: Devosia_sp_PTEAB7WZ <int>, Labrenzia_sp_PT13C1 <int>

# type changes output

    Code
      read_orthogroups(test_path("fixtures", "Orthogroups.tsv"), type = "lists")
    Message
      Orthogroups.tsv contains 11 orthogroups across 5 genomes
    Output
      # A tibble: 11 x 6
         Orthogroup Alcanivorax_sp_EA2 Algoriphagus_sp_ARW1R1 Arenibacter_sp_ARW7G5Y1
         <chr>      <list>             <list>                 <list>                 
       1 OG0000000  <chr [53]>         <chr [22]>             <chr [29]>             
       2 OG0000001  <chr [27]>         <chr [22]>             <chr [36]>             
       3 OG0000002  <chr [23]>         <chr [23]>             <chr [21]>             
       4 OG0000003  <chr [29]>         <chr [13]>             <chr [13]>             
       5 OG0000004  <chr [7]>          <chr [3]>              <chr [4]>              
       6 OG0000005  <NULL>             <chr [6]>              <chr [5]>              
       7 OG0000006  <NULL>             <NULL>                 <chr [2]>              
       8 OG0000007  <chr [13]>         <chr [18]>             <chr [43]>             
       9 OG0000008  <chr [23]>         <chr [3]>              <chr [5]>              
      10 OG0000009  <chr [1]>          <chr [1]>              <chr [1]>              
      11 OG0000010  <chr [1]>          <chr [1]>              <chr [1]>              
      # i 2 more variables: Devosia_sp_PTEAB7WZ <list>, Labrenzia_sp_PT13C1 <list>

