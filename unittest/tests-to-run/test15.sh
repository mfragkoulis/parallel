#!/bin/bash

# Test xargs compatibility

echo '### Test -p --interactive'
cat >/tmp/parallel-script-for-expect <<_EOF
#!/bin/bash

seq 1 3 | parallel -k -p  echo opt-p
seq 1 3 | parallel -k --interactive  echo opt--interactive
_EOF
chmod 755 /tmp/parallel-script-for-expect

expect -b - <<_EOF
spawn /tmp/parallel-script-for-expect
expect "echo opt-p 1"
send "y\n"
expect "echo opt-p 2"
send "n\n"
expect "echo opt-p 3"
send "y\n"
expect "opt-p 1"
expect "opt-p 3"
expect "echo opt--interactive 1"
send "y\n"
expect "echo opt--interactive 2"
send "n\n"
expect "echo opt--interactive 3"
send "y\n"
expect "opt--interactive 1"
expect "opt--interactive 3"
_EOF


echo '### Test -L -l and --max-lines'
(echo a_b;echo c) | parallel -km -L2  echo
(echo a_b;echo c) | parallel -k -L2  echo
(echo a_b;echo c) | xargs -L2  echo
(echo a_b;echo c) | parallel -km -L1  echo
(echo a_b;echo c) | parallel -k -L1  echo
(echo a_b;echo c) | xargs -L1  echo
(echo a_b' ';echo c;echo d) | parallel -km -L1  echo
(echo a_b' ';echo c;echo d) | parallel -k -L1  echo
(echo a_b' ';echo c;echo d) | xargs -L1  echo
(echo a_b' ';echo c;echo d;echo e) | parallel -km -L2 echo
(echo a_b' ';echo c;echo d;echo e) | parallel -k -L2 echo
(echo a_b' ';echo c;echo d;echo e) | xargs -L2 echo
(echo a_b' ';echo c;echo d;echo e) | parallel -km -l echo
(echo a_b' ';echo c;echo d;echo e) | parallel -k -l echo
(echo a_b' ';echo c;echo d;echo e) | xargs -l echo
(echo a_b' ';echo c;echo d;echo e) | parallel -km -l2 echo
(echo a_b' ';echo c;echo d;echo e) | parallel -k -l2 echo
(echo a_b' ';echo c;echo d;echo e) | xargs -l2 echo
(echo a_b' ';echo c;echo d;echo e) | parallel -km -l1 echo
(echo a_b' ';echo c;echo d;echo e) | parallel -k -l1 echo
(echo a_b' ';echo c;echo d;echo e) | xargs -l1 echo
(echo a_b' ';echo c;echo d;echo e) | parallel -km --max-lines 2 echo
(echo a_b' ';echo c;echo d;echo e) | parallel -k --max-lines 2 echo
(echo a_b' ';echo c;echo d;echo e) | xargs --max-lines=2 echo
(echo a_b' ';echo c;echo d;echo e) | parallel -km --max-lines echo
(echo a_b' ';echo c;echo d;echo e) | parallel -k --max-lines echo
(echo a_b' ';echo c;echo d;echo e) | xargs --max-lines echo

echo '### test too long args'
perl -e 'print "z"x1000000' | parallel echo 2>&1
perl -e 'print "z"x1000000' | xargs echo 2>&1
(seq 1 10; perl -e 'print "z"x1000000'; seq 12 15) | stdout parallel -j1 -km -s 10 echo
(seq 1 10; perl -e 'print "z"x1000000'; seq 12 15) | stdout xargs -s 10 echo
(seq 1 10; perl -e 'print "z"x1000000'; seq 12 15) | stdout parallel -j1 -k -s 10 echo
echo '### Test -x'
(seq 1 10; echo 12345; seq 12 15) | stdout parallel -j1 -km -s 10 -x echo
(seq 1 10; echo 12345; seq 12 15) | stdout parallel -j1 -k -s 10 -x echo
(seq 1 10; echo 12345; seq 12 15) | stdout xargs -s 10 -x echo
(seq 1 10; echo 1234; seq 12 15) | stdout parallel -j1 -km -s 10 -x echo
(seq 1 10; echo 1234; seq 12 15) | stdout parallel -j1 -k -s 10 -x echo
(seq 1 10; echo 1234; seq 12 15) | stdout xargs -s 10 -x echo
echo '### Test bugfix if no command given'
(echo echo; seq 1 5; perl -e 'print "z"x1000000'; seq 12 15) | stdout parallel -j1 -km -s 10



echo '### Test -a and --arg-file: Read input from file instead of stdin'
seq 1 10 >/tmp/$$
parallel -k -a /tmp/$$ echo
parallel -k --arg-file /tmp/$$ echo

cd input-files/test15

echo 'xargs Expect: 3 1 2'
echo 3 | xargs -P 1 -n 1 -a files cat -
echo 'parallel Expect: 3 1 2'
echo 3 | parallel -k -P 2 -n 1 -a files cat -
echo 'xargs Expect: 1 3 2'
echo 3 | xargs -I {} -P 1 -n 1 -a files cat {} -
echo 'parallel Expect: 1 3 2'
echo 3 | parallel -k -I {} -P 1 -n 1 -a files cat {} -

echo '### Test -i and --replace: Replace with argument'
(echo a; echo END; echo b) | parallel -k -i -eEND echo repl{}ce
(echo a; echo END; echo b) | parallel -k --replace -eEND echo repl{}ce
(echo a; echo END; echo b) | parallel -k -i+ -eEND echo repl+ce
(echo e; echo END; echo b) | parallel -k -i'*' -eEND echo r'*'plac'*'
(echo a; echo END; echo b) | parallel -k --replace + -eEND echo repl+ce
(echo a; echo END; echo b) | parallel -k --replace== -eEND echo repl=ce
(echo a; echo END; echo b) | parallel -k --replace = -eEND echo repl=ce
(echo a; echo END; echo b) | parallel -k --replace=^ -eEND echo repl^ce
(echo a; echo END; echo b) | parallel -k -I^ -eEND echo repl^ce

echo '### Test -E: Artificial end-of-file'
(echo include this; echo END; echo not this) | parallel -k -E END echo
(echo include this; echo END; echo not this) | parallel -k -EEND echo

echo '### Test -e and --eof: Artificial end-of-file'
(echo include this; echo END; echo not this) | parallel -k -e END echo
(echo include this; echo END; echo not this) | parallel -k -eEND echo
(echo include this; echo END; echo not this) | parallel -k --eof=END echo
(echo include this; echo END; echo not this) | parallel -k --eof END echo

echo '### Test -n and --max-args: Max number of args per line (only with -X and -m)'
(echo line 1;echo line 2;echo line 3) | parallel -k -n1 -m echo
(echo line 1;echo line 1;echo line 2) | parallel -k -n2 -m echo
(echo line 1;echo line 2;echo line 3) | parallel -k -n1 -X echo
(echo line 1;echo line 1;echo line 2) | parallel -k -n2 -X echo
(echo line 1;echo line 2;echo line 3) | parallel -k -n1 echo
(echo line 1;echo line 1;echo line 2) | parallel -k -n2 echo
(echo line 1;echo line 2;echo line 3) | parallel -k --max-args=1 -X echo
(echo line 1;echo line 2;echo line 3) | parallel -k --max-args 1 -X echo
(echo line 1;echo line 1;echo line 2) | parallel -k --max-args=2 -X echo
(echo line 1;echo line 1;echo line 2) | parallel -k --max-args 2 -X echo
(echo line 1;echo line 2;echo line 3) | parallel -k --max-args 1 echo
(echo line 1;echo line 1;echo line 2) | parallel -k --max-args 2 echo

echo '### Test --max-procs and -P: Number of processes'
seq 1 10 | parallel -k --max-procs +0 echo max proc
seq 1 10 | parallel -k -P 200% echo 200% proc

echo '### Test --delimiter and -d: Delimiter instead of newline'
echo '# Yes there is supposed to be an extra newline for -d N'
echo line 1Nline 2Nline 3 | parallel -k -d N echo This is
echo line 1Nline 2Nline 3 | parallel -k --delimiter N echo This is
printf "delimiter NUL line 1\0line 2\0line 3" | parallel -k -d '\0' echo
printf "delimiter TAB line 1\tline 2\tline 3" | parallel -k --delimiter '\t' echo

echo '### Test --max-chars and -s: Max number of chars in a line'
(echo line 1;echo line 1;echo line 2) | parallel -k --max-chars 25 -X echo
(echo line 1;echo line 1;echo line 2) | parallel -k -s 25 -X echo

echo '### Test --no-run-if-empty and -r: This should give no output'
echo "  " | parallel -r echo
echo "  " | parallel --no-run-if-empty echo

echo '### Test --help and -h: Help output (just check we get the same amount of lines)'
echo Output from -h and --help
parallel -h | wc -l
parallel --help | wc -l

echo '### Test --version: Version output (just check we get the same amount of lines)'
parallel --version | wc -l

echo '### Test --verbose and -t'
(echo b; echo c; echo f) | parallel -k -t echo {}ar 2>&1 >/dev/null
(echo b; echo c; echo f) | parallel -k --verbose echo {}ar 2>&1 >/dev/null

echo '### Test --show-limits'
(echo b; echo c; echo f) | parallel -k --show-limits echo {}ar
(echo b; echo c; echo f) | parallel -k --show-limits -s 100 echo {}ar
