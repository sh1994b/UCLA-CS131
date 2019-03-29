import java.util.concurrent.locks.StampedLock;

class BetterSafeState implements State 
{
	private byte[] value;
	private byte maxval;
	private final StampedLock sl = new StampedLock();

	BetterSafeState(byte[] v) { value = v; maxval = 127; }
	BetterSafeState(byte[] v, byte m) { value = v; 	maxval = m; }

	public int size() { return value.length; }

	public byte[] current() { return value; }

	public boolean swap(int i, int j)
	{
		if (value[i] <= 0 && value[j] >= maxval)
			return false;
		
		long stamp = sl.readLock();
		try {
			if (value[i] > 0 && value[j] < maxval) {
	            		long ws = sl.tryConvertToWriteLock(stamp);
				if (ws != 0L) {
					stamp = ws;
					value[i]--;
			                value[j]++;
				}
				else {
					sl.unlockRead (stamp);
					stamp = sl.writeLock();
				}
			}
		    } 
		finally {
				sl.unlock(stamp);
			} 
        		
        	return true;
	}
}
