#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

### setup is the same
. $(dirname $0)/es_settings

### Resume game if the system was shut down during gameplay
RESUME_FILE="/storage/.config/resume_game"
if [ -f "${RESUME_FILE}" ]; then
  . "${RESUME_FILE}"
  if [ -n "${RESUME_ROM}" ] && [ -n "${RESUME_PLATFORM}" ] && [ -n "${RESUME_CORE}" ] && [ -n "${RESUME_EMULATOR}" ]; then
    logger -t start_es "Resuming game: ${RESUME_ROM}"

    # Launch the game in the background
    /usr/bin/runemu.sh "${RESUME_ROM}" -P${RESUME_PLATFORM} --core=${RESUME_CORE} --emulator=${RESUME_EMULATOR} &
    GAME_PID=$!

    # Wait for RetroArch to start, then send LOAD_STATE
    sleep 5
    logger -t start_es "Sending LOAD_STATE to RetroArch"
    echo -n "LOAD_STATE" | nc -u -w1 127.0.0.1 55355

    # Wait for the game to exit
    wait ${GAME_PID}

    # Clean up - runemu.sh already removes resume_game on normal exit,
    # but ensure it's gone in case of unexpected exit
    rm -f "${RESUME_FILE}"
  else
    # Invalid resume file, clean up
    rm -f "${RESUME_FILE}"
  fi
fi

emulationstation --log-path /var/log --no-splash
