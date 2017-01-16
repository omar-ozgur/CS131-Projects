import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSetState implements State {
    private byte maxval;
    private AtomicIntegerArray atomicIntegerArray;

    GetNSetState(byte[] v) {
        maxval = 127;

        // Convert the given byte array to an int array so that it can be used
        // in the constructor of the AtomicIntegerArray class.
        int[] temp = new int[v.length];
        for(int i = 0; i < v.length; i++){
            temp[i] = (int) v[i];
        }
        atomicIntegerArray = new AtomicIntegerArray(temp);
    }

    GetNSetState(byte[] v, byte m) {
        maxval = m;
        // Convert the given byte array to an int array so that it can be used
        // in the constructor of the AtomicIntegerArray class.
        int[] temp = new int[v.length];
        for(int i = 0; i < v.length; i++){
            temp[i] = (int) v[i];
        }
        atomicIntegerArray = new AtomicIntegerArray(temp);
    }

    public int size() {
        return atomicIntegerArray.length();
    }

    public byte[] current() {
        // Convert the current AtomicIntegerArray object to a byte array that
        // can be returned by the function.
        byte[] res = new byte[atomicIntegerArray.length()];
        for(int i = 0; i < atomicIntegerArray.length(); i++){
            res[i] = (byte) atomicIntegerArray.get(i);
        }
        return res;
    }

    // Using AtomicIntegerArray methods allows for threads to read/write data to/from
    // the object without worrying about race conditions or deadlocks.
    public boolean swap(int i, int j) {
	if (atomicIntegerArray.get(i) <= 0 || atomicIntegerArray.get(j) >= maxval) {
	    return false;
	}
        atomicIntegerArray.set(i, atomicIntegerArray.get(i) - 1); 
        atomicIntegerArray.set(j, atomicIntegerArray.get(j) + 1);
	return true;
    }
}
