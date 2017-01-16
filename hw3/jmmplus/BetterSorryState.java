import java.util.concurrent.atomic.AtomicInteger;

class BetterSorryState implements State {
    private AtomicInteger[] atomicIntegers;
    private byte maxval;

    BetterSorryState(byte[] v) {
        maxval = 127;
        atomicIntegers = new AtomicInteger[v.length];
        for (int i = 0; i < v.length; i++) {
            atomicIntegers[i] = new AtomicInteger(v[i]);
        }
    }

    BetterSorryState(byte[] v, byte m) {
        maxval = m; 
        atomicIntegers = new AtomicInteger[v.length];
        for (int i = 0; i < v.length; i++) {
            atomicIntegers[i] = new AtomicInteger(v[i]);
        }
    }

    public int size() { return atomicIntegers.length; }

    public byte[] current() {
        byte[] temp = new byte[atomicIntegers.length];
        for (int i = 0; i < atomicIntegers.length; i++) {
            temp[i] = (byte) atomicIntegers[i].intValue();
        }
        return temp;
    }

    // By using individual atomic integers for each element in the array,
    // the swaps can perform faster due to the advantages of fine-grained
    // locking. However, since the threads can be preempted after checking
    // For edge cases, it is possible for race conditions to occur.
    public boolean swap(int i, int j) {
        if (atomicIntegers[i].get() <= 0 || atomicIntegers[j].get() >= maxval) {
            return false;
        }
        atomicIntegers[i].getAndDecrement();
        atomicIntegers[j].getAndIncrement();
        return true;
    }
}
