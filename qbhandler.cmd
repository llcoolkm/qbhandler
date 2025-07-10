@echo off
python "C:\Users\km\git\qbhandler\qbhandler.py" %*
if %errorlevel% neq 0 (
    echo Script exited with error code %errorlevel%.
    pause
)
