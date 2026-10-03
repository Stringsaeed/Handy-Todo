#!/usr/bin/env python3
"""Seed handy's SQLite store (SwiftData, Core Data schema) on a simulator with demo tasks.

Usage: python3 seed-simulator.py <simulator-udid> [--empty] [--more]
The app must not be running. Dates are relative to today in the host time zone.
"""
import datetime as dt
import glob
import os
import sqlite3
import subprocess
import sys
import uuid

BUNDLE = "com.stringsaeed.handy.todo"
EPOCH = dt.datetime(2001, 1, 1, tzinfo=dt.timezone.utc)

# (text, category, day offset, hour, minute, finished)
TASKS = [
    ("finish the pitch deck", "Primary", 0, 10, 30, False),
    ("call mom back", "Primary", 0, 18, 0, False),
    ("book the dentist", "Primary", 0, 9, 0, True),
    ("plan the weekend hike", "Secondary", 1, 9, 0, False),
    ("water the plants", "Secondary", 0, 17, 30, False),
    ("reply to sara's email", "Secondary", 0, 11, 15, True),
    ("try that new ramen place", "Tertiary", 2, 19, 30, False),
    ("read 20 pages", "Tertiary", 0, 21, 0, False),
    ("stretch for ten minutes", "Tertiary", 0, 8, 0, True),
]

# Extra tasks for taller layouts such as iPad columns (--more).
MORE_TASKS = [
    ("prep notes for the 1:1", "Primary", 0, 14, 0, False),
    ("renew passport", "Primary", 1, 10, 0, False),
    ("submit the expense report", "Primary", 0, 12, 0, True),
    ("pick up dry cleaning", "Secondary", 0, 16, 0, False),
    ("book train tickets", "Secondary", 1, 12, 0, False),
    ("back up the laptop", "Secondary", 0, 20, 0, True),
    ("learn three chords", "Tertiary", 2, 18, 0, False),
    ("sort the photo library", "Tertiary", 3, 11, 0, False),
    ("make a playlist for the drive", "Tertiary", 0, 22, 0, True),
]


def core_data_time(when: dt.datetime) -> float:
    return (when - EPOCH).total_seconds()


def main() -> None:
    udid = sys.argv[1]
    empty = "--empty" in sys.argv
    tasks = TASKS + (MORE_TASKS if "--more" in sys.argv else [])
    data = subprocess.check_output(
        ["xcrun", "simctl", "get_app_container", udid, BUNDLE, "data"], text=True).strip()
    store = glob.glob(os.path.join(data, "Library", "Application Support", "HandyTodo.sqlite"))[0]

    db = sqlite3.connect(store)
    db.execute("DELETE FROM ZTODOITEM")
    if not empty:
        today = dt.datetime.now().astimezone().replace(second=0, microsecond=0)
        for index, (text, category, offset, hour, minute, finished) in enumerate(tasks, start=1):
            due = (today + dt.timedelta(days=offset)).replace(hour=hour, minute=minute)
            created = today - dt.timedelta(minutes=len(tasks) - index)
            db.execute(
                "INSERT INTO ZTODOITEM (Z_PK, Z_ENT, Z_OPT, ZISFINISHED, ZDATE, ZTIMESTAMP, ZCATEGORY, ZTEXT, ZID)"
                " VALUES (?, 1, 1, ?, ?, ?, ?, ?, ?)",
                (index, int(finished), core_data_time(due), core_data_time(created), category, text,
                 uuid.uuid4().bytes))
    db.execute("UPDATE Z_PRIMARYKEY SET Z_MAX = ? WHERE Z_NAME = 'TodoItem'", (0 if empty else len(tasks),))
    db.commit()
    db.execute("PRAGMA wal_checkpoint(TRUNCATE)")
    db.close()
    print(f"seeded {0 if empty else len(tasks)} tasks into {store}")


if __name__ == "__main__":
    main()
