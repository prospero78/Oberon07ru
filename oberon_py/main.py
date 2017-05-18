# -*- coding: utf8 -*-
'''
Небольшой проект по написанию компилятора для Оберона
Лицензия BSD-2.
'''

import pakOberon.modUtil as mUtil
import pakOberon.modError as mErr
import pakOberon.modErrorConstante as mErrConst

def Start():
    if mUtil.param_all<2:
        mErr.Msg(mErrConst.msgParamFew)

if __name__=='__main__':
    Start()
