
export CBLACK="\033[0;30m"
export CRED="\033[0;31m"
export CGREEN="\033[0;32m"
export CYELLOW="\033[0;33m"
export CBLUE="\033[0;34m"
export CPINK="\033[0;35m"
export CCYAN="\033[0;36m"
export CWHITE="\033[0;37m"
export CDEFAULT="\033[0m"

function echo-err { echo "$@" 1>&2; }

function date-today { echo $(date +%F); }
function date-second { echo $(date +%F_%H-%M-%S); }
function date-YYYYmmdd { echo $(date +%Y%m%d); }
function date-8601 { date -u +%Y-%m-%dT%H:%M:%S%z; }
function date-8601-local { date +%Y-%m-%dT%H:%M:%S%z; }
function date-8601-utc-simple { echo `date -u +%Y-%m-%dT%H-%M-%S`Z; }
function date-8601-local-simple { date +%Y-%m-%dT%H-%M-%S%z; }
function log-8601 { echo "[ $(date-8601) ] $@"; }
function log-8601-local { echo "[ $(date-8601-local) ] $@"; }
function log-err-8601 { echo-err "[ $(date-8601) ] $@"; }
function log-err-8601-local { echo-err "[ $(date-8601-local) ] $@"; }

function ask { echo -ne "${CYELLOW} $1: ${CDEFAULT}"; read ASK; export ASK; }
function ask-default { echo -ne "${CYELLOW} $1 [$2]: ${CDEFAULT}"; read ASK; export ASK=${ASK:-$2}; }
function ask-yes { echo -ne "${CYELLOW} $1 [Y/n]: ${CDEFAULT}"; read ASK; ASK="$(echo $ASK | tr '[:upper:]' '[:lower:]' | head -c 1)"; export ASK=${ASK:-y}; }
function ask-no { echo -ne "${CYELLOW} $1 [y/N]: ${CDEFAULT}"; read ASK; ASK="$(echo $ASK | tr '[:upper:]' '[:lower:]' | head -c 1)"; export ASK=${ASK:-n}; }
function ask-enter { echo -e "${CYELLOW} $1: [Press enter to continue]${CDEFAULT}" ; read; }
function ask-password { echo -ne "${CYELLOW} $1: ${CDEFAULT}" ; read -s ASK; echo; }

function msg-error { echo -e "${CRED}${@}${CDEFAULT}"; }
function msg-info { echo -e "${CCYAN}${@}${CDEFAULT}"; }
function msg-success { echo -e "${CGREEN}${@}${CDEFAULT}"; }
function msg-dry { echo -e "${CPINK}${@}${CDEFAULT}"; }

function trim-leading { echo "$1" | sed -e 's/^[[:space:]]*//'; }
function trim-trailing { echo "$1" | sed -e 's/[[:space:]]*$//'; }
function trim { trim-leading `trim-trailing "$1"`; }
