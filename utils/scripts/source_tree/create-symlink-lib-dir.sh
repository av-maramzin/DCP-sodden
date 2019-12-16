#!/usr/bin/env bash

# internal vars

OP_MODE_STR="create symlinks"

OUTS='/dev/stdout'
ERRS='/dev/stderr'


# initialize configuration vars

SHOW_HELP=0
LIB_RM_LINKS=0
LIB_SOURCE_DIR=""
LIB_TARGET_DIR=""
declare -a LIB_SUBDIRS


# parse and check cmd line options

CMDOPTS=":s:t:l:Rqh"

HELP_STRING="\
Usage: ${0} OPTIONS

-s dir     library source directory
-t dir     library target directory
-l subdir  benchmark subdir (use multiple times for more than one subdirs)
-R         remove symlinks to subdirs (default is adding symlinks)
-q         silent mode (no output)
-h         help
"

while getopts ${CMDOPTS} cmdopt; do
  case $cmdopt in
    s)
      LIB_SOURCE_DIR=$OPTARG
      ;;
    t)
      LIB_TARGET_DIR=$OPTARG
      ;;
    l)
      LIB_SUBDIRS=("${LIB_SUBDIRS[@]}" "${OPTARG}")
      ;;
    R)
      LIB_RM_LINKS=1
      OP_MODE_STR="remove symlinks"
      ;;
    q)
      OUTS="/dev/null"
      ERRS="/dev/null"
      ;;
    h)
      SHOW_HELP=1
      ;;
    \?)
      echo "error: invalid option: -$OPTARG" > $ERRS
      exit 1
      ;;
    :)
      echo "error: option -$OPTARG requires an argument" > $ERRS
      exit 1
      ;;
  esac
done


if [ "$SHOW_HELP" -ne 0 ]; then
  echo "$HELP_STRING" > $ERRS

  exit 0
fi

if [ -z ${LIB_SOURCE_DIR:+x} -o ! -e ${LIB_SOURCE_DIR} ]; then
  echo "error: library source dir was not provided or does not exist" > $ERRS

  exit 1
fi

if [ -z ${LIB_TARGET_DIR:+x} -o ! -e ${LIB_TARGET_DIR} ]; then
  echo "error: library target dir was not provided or does not exist" > $ERRS

  exit 1
fi

if [ "${#LIB_SUBDIRS[@]}" -eq 0 ]; then
  echo "error: library subdirs were not provided" > $ERRS

  exit 1
fi

# print configuration vars

INFO_STR="\
info: printing configuration vars
info: operation mode: ${OP_MODE_STR}
info: benchmark source dir: ${LIB_SOURCE_DIR}
info: benchmark target dir: ${LIB_TARGET_DIR}
info: benchmark subdirs: "

echo -n "$INFO_STR" > $OUTS
for LIB_SUBDIR in ${LIB_SUBDIRS[@]}; do
  echo -n "${LIB_SUBDIR} " > $OUTS
done
echo ""

# operations

# check if out dir location is given in relative form
if [ "${LIB_SOURCE_DIR}" == "${LIB_SOURCE_DIR#/}" ]; then
  LIB_SOURCE_DIR="$(pwd)/${LIB_SOURCE_DIR}"
fi

# 2 modes of operation
if [ "$LIB_RM_LINKS" -eq 0 ]; then
    # mode: create symlinks, if targets exist

    for LIB_SUBDIR in "${LIB_SUBDIRS[@]}"; do
      # trim whitespace
      LIB_SUBDIR=$(echo $LIB_SUBDIR | xargs)

      [ -z ${LIB_SUBDIR} ] && continue

      ABSOLUTE_LIB_SUBDIR="${LIB_SOURCE_DIR}/${LIB_SUBDIR}"
      echo "${ABSOLUTE_LIB_SUBDIR}" > $OUTS

      [ ! -d ${ABSOLUTE_LIB_SUBDIR} ] && continue

      pushd "${LIB_TARGET_DIR}/" > $OUTS

      ln -sf ${ABSOLUTE_LIB_SUBDIR}

      popd > $OUTS
    done
else
    # mode: remove symlinks

    for LIB_SUBDIR in "${LIB_SUBDIRS[@]}"; do
      # trim whitespace
      LIB_SUBDIR=$(echo $LIB_SUBDIR | xargs)

      pushd "${LIB_TARGET_DIR}/" > $OUTS

      [ -L "${LIB_SUBDIR}" ] && rm -f "${LIB_SUBDIR}"

      popd > $OUTS
    done
fi

exit $?
