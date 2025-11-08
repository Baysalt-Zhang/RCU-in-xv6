#!/usr/bin/env python3

import re
import sys
from gradelib import *

r = Runner(save("xv6.out"))

@test(0, "running threadtest")
def test_threadtest():
    r.run_qemu(shell_script([
        'threadtest'
    ]))

@test(10, "threadmtest: test1", parent=test_threadtest)
def test_threadtest_test1():
    r.match('^TEST1 PASSED$')

@test(10, "threadmtest: test2", parent=test_threadtest)
def test_threadtest_test2():
    r.match('^TEST2 PASSED$')

@test(40, "threadmtest: test3", parent=test_threadtest)
def test_threadtest_test3():
    r.match('^TEST3 PASSED$')

@test(10, "threadmtest: test4", parent=test_threadtest)
def test_threadtest_test4():
    r.match('^TEST4 PASSED$')

@test(10, "threadmtest: test5", parent=test_threadtest)
def test_threadtest_test5():
    r.match('^TEST5 PASSED$')

@test(10, "threadmtest: test6", parent=test_threadtest)
def test_threadtest_test6():
    r.match('^TEST6 PASSED$')

@test(10, "usertests")
def test_usertests():
    r.run_qemu(shell_script([
        'usertests'
    ]), timeout=300)
    r.match('^ALL TESTS PASSED$')

if __name__ == '__main__':
    if len(sys.argv) > 1:
        run_tests(outputJSON=sys.argv[1])
    else:
        run_tests()