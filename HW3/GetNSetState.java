import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSetState implements State 
{
	private byte[] value;
	private byte maxval;

	GetNSetState(byte[] v) { value = v; maxval = 127;}
	GetNSetState(byte[] v, byte m) { value = v; maxval = m; }

	public int size() { return value.length; }

	public byte[] current() { return value; }	

	public boolean swap(int i, int j) 
	{
		AtomicIntegerArray aia = new AtomicIntegerArray(size());
		for (int k = 0; k < size(); k++)
			aia.set(k, value[k]);

		if (aia.get(i) <= 0 || aia.get(j) >= maxval)
			return false;
		
		aia.set(i, aia.get(i)-1);
		aia.set(j, aia.get(j)+1);
		return true;
	}
}
