# Governance

The laboratory keeps a governed log with three sections: human decisions,
incidents (defects that required a correction, each recorded with a root
cause and a lesson), and standing rules (each linked to the incidents that
led to it).

The process:

    incident recorded → the same root cause occurs a second time →
    an amendment is drafted automatically from the recorded lessons →
    the human approves or rejects → standing rule + automated check

Current tallies, as counts of recorded entries: 27 human decisions (most
of them single-line), 42 recorded incidents, 10 standing rules — two of
which were drafted by the system itself and approved by the human.

Every confirmed review finding is converted into an automated regression
test, so the same question does not need to be raised twice.

The resulting division of labor: the human contributes judgment,
standards, and final decisions; the system contributes exhaustive
computation, consistent record-keeping, and repeatable verification.
