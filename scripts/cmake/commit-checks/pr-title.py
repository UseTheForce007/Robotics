#!/usr/bin/python3
import argparse, re


# * Ensuring a line limit.
def __summaryCheck(msg: str):
    summary = msg.partition("\n")[0]
    msgSummaryLen = len(summary)
    if msgSummaryLen >= 50:
        raise ValueError(f"Message summary must be less than 60. Is: {msgSummaryLen}")


# * Ensure we have a [#123] start to the message.
def __issueCheck(msg: str):
    if not re.match("\[#\d+\]\ ", msg):
        raise ValueError(f"Message not of the form: [#XX] My commit message.")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("msg", help="Commit message to check.")
    args = parser.parse_args()
    msg: str = args.msg
    print(f"msg: {msg}")
    __issueCheck(msg)
    __summaryCheck(msg)


if __name__ == "__main__":
    main()
