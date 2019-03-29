
fun everyNth(L: List<Any>, N:Int): List<Any> {
	val len = L.count()  //length of list
	var result: MutableList<Any> = mutableListOf<Any>()
	var M = 1
	var ind = M*N-1
	while (ind < len) {
		result.add(L[ind])
		M = M+1
		ind = M*N-1
	}
	return result
}

fun main() {
	val lst1 = listOf(1,2,3,4,5,6,7,8,9,10)
	val lst2 = listOf("Hi", "My", "Name", "Is", "Shab")
	val lst3 = listOf<Int>()
	val lst4 = listOf(1,2,3)

	println("Running list [1,2,3,4,5,6,7,8,9,10] with N = 2")
	val test1 = everyNth(lst1,2)
	if (test1 == mutableListOf(2, 4, 6, 8, 10)) {
		println("test1 had correct return value:")
		println(test1)
	}
	else 
		println("test1 failed")

	println("Running list [1,2,3,4,5,6,7,8,9,10] with N = 4")
	val test2 = everyNth(lst1,4)
        if (test2 == mutableListOf(4,8)) {
                println("test2 had correct return value:")
                println(test2)
        }
	else
                println("test2 failed")

	println("Running list [Hi, My, Name, Is, Shab] with N = 1")
        val test3 = everyNth(lst2,1)
        if (test3 == mutableListOf("Hi", "My", "Name", "Is", "Shab")) {
                println("test3 had correct return value:")
                println(test3)
        }
        else
                println("test3 failed")

	println("Running list [] with N = 4")
        val test4 = everyNth(lst3,4)
        if (test4 == mutableListOf<Int>()) {
                println("test4 had correct return value:")
                println(test4)
        }
        else
                println("test4 failed")

	println("Running list [1,2,3] with N = 4")
        val test5 = everyNth(lst4,4)
        if (test5 == mutableListOf<Int>()) {
                println("test5 had correct return value:")
                println(test5)
        }
        else
                println("test5 failed")
}
