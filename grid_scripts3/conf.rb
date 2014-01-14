
#0 PARALLEL, 1 ITERATIVE
PARALLEL_OR_ITERATIVE = 1
PARALLEL_TIME_SLEEP = 60

PATH="~/ADC/scientific_analysis/"

#0 no remote shell, 1 remote shell
#A file token contain
#host, token
#if token = 0 transfer only process
#if token > 1 transfer data and process
REMOTE_SHELL_COMMAND_MULTI = 0

SRCLOCCONFLEVEL = 5.9914659
SQRTTS_CUTTONEXTSTEP = 2.0

#BASEDIR_ARCHIVE = "/scratch1/users/bulgarelli/ARCHIVE/"
#BASEDIR_ARCHIVE = "/ARCHIVE/"
BASEDIR_ARCHIVE = "/AGILE_PROC3/"

TYPE_MATRIX = "I0023"

#ARCHIVE_ID = 0 BUILD17, 1 = BUILD15 or 16
ARCHIVE_ID = 0

load "~/grid_scripts3/DataUtils.rb"
load "~/grid_scripts3/AgileFOV.rb"
load "~/grid_scripts3/MultiOutput.rb"
load "~/grid_scripts3/AlikeUtils.rb"
load "~/grid_scripts3/DataConversion.rb"
load "~/grid_scripts3/Parameters.rb"

load "date.rb"
