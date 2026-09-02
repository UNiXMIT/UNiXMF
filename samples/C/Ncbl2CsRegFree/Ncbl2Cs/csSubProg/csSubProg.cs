using System;
using System.Text;
using System.Runtime.InteropServices;
using MicroFocus.COBOL.Program;

namespace csSubProg
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	public class csSubProg
	{    
	    public csSubProg()
		{
		   		   
		}
		public int csEntryPoint(ref string wsString10, ref Int32 wsInteger)
		{
           Console.WriteLine("[Now in csSubProg]");
           Console.WriteLine("Parameters received as:");
           Console.WriteLine("wsString10 = " + wsString10);
           Console.WriteLine("wsInteger  = " + wsInteger);
           Console.WriteLine("");
           Console.WriteLine("Parameters modified as:");
           wsString10 = "Hello";
           wsInteger = 123;
		   Console.WriteLine("wsString10 = " + wsString10);
           Console.WriteLine("wsInteger  = " + wsInteger);
           return (100);		   		   		   		   		
		}		
	}
}
