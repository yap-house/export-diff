#EXPORT DIFF DATA
export DIFFPATH=""
function export_diff() {
  local error=""
  local diff=""
  local output=""
  local msg=""
  local head="HEAD"
  local date=$(date '+%m%d-%H-%M')
  local file_name=$(basename `pwd`)
  local current=$(echo `pwd` | sed -e "s/\/$file_name//")

  if [ "$DIFFPATH" != "" ]; then
      output="${DIFFPATH}/${file_name}${date}.zip"
  else
      output="${current}/${file_name}${date}.zip"
  fi

  if [ $# -eq 1 ]; then
      if expr "$1" : "^[0-9]\{1,2\}$" > /dev/null ; then
          diff="HEAD HEAD~${1}"
      else
          diff="HEAD ${1}"
      fi

  elif [ $# -eq 2 ]; then
      diff="${1} ${2}"
      head=$1
  fi

  if [ "$diff" != "" ]; then
      local exists_files=""
      local diff_files=""
      local git_files=$(git ls-files)

      diff=$(git diff --name-only $diff)

      for val in ${diff}
      do
          if [ -e ${val} ]; then
              exists_files="${exists_files} ${val}"

          else
              error="${error} ${val}"
          fi
      done

      if [ "$exists_files" != "" ]; then
          for val in ${exists_files}
          do
              if [ `echo ${git_files} | grep ${val} | sed -e s/\ //g` ]; then
                  diff_files="${diff_files} ${val}"
              fi
          done
      fi

      diff=$diff_files

      if [ "$diff" != "" ]; then
          msg="export diff data: output destination is '${output}'"

      else
          msg="export all data: output destination is '${output}'"
      fi

  else
      msg="export all data: output destination is '${output}'"
  fi

  if [ "$error" != "" ]; then
      echo "These files is not found:"
      for val in ${error}
      do
          echo ${val}
      done
  fi

  echo $msg
  git archive --format=zip --prefix=$file_name/ $head $diff -o $output
}
