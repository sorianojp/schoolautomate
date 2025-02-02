<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<%@ page language="java" import="utility.*,lms.LmsUtil,lms.CatalogReport,java.util.Vector" %>

<%
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	WebInterface WI   = new WebInterface(request);
	Vector vRetResult = new Vector();

//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
	CatalogReport CR = new CatalogReport();
	vRetResult = CR.generateReportCard(dbOP, request);

if(vRetResult == null || vRetResult.size() == 0) {
	dbOP.cleanUP();
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=CR.getErrMsg()%></font></p>
	<%
	return;
}
%>

<body onLoad="javascript:window.print();">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font><br>
		<font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
				
		</font></div></td>
    </tr>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="15"><%=WI.getTodaysDateTime()%></td>
      <td align="right">Page 1&nbsp;&nbsp;</td>
    </tr>
    <tr> 
      <td height="20" colspan="2"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">  
<%
strTemp = WI.fillTextValue("lines_per_pg");
int iLinesPerPg = 50;
if(strTemp.length() > 0) 
	iLinesPerPg = Integer.parseInt(strTemp);

strTemp = WI.fillTextValue("char_per_pg");
int iCharPerLine = 70;
if(strTemp.length() > 0) 
	iCharPerLine = Integer.parseInt(strTemp);	
int iPageCount = 1; int iCurLineNo = 0;	int iCurChar = 0; boolean bolPageBreak = false;
%>
	<tr> 
	  <td height="10" width="15%">Call No.</td>
	  <td height="10" width="25%">Book Title</td>
	  <td height="10" width="17%">Publication Place</td>
	  <td height="10" width="19%">Publisher</td>
	  <td height="10" width="7%">Copyright</td>
	  <td height="10" width="10%">ISBN No.</td>
	  <td height="10" width="7%">Copies</td>
	</tr>

<%for(int i = 0; i < vRetResult.size(); i += 11){
	iCurLineNo += 2;
	iCurChar = WI.getStrValue(vRetResult.elementAt(i)).length(); //call number
	iCurChar += WI.getStrValue(vRetResult.elementAt(i + 4)).length(); // book title
	iCurChar += WI.getStrValue(vRetResult.elementAt(i + 7)).length(); // publication place
	iCurChar += WI.getStrValue(vRetResult.elementAt(i + 8)).length(); // publisher
	iCurChar += WI.getStrValue(vRetResult.elementAt(i + 9)).length();  // copyright
	iCurChar += WI.getStrValue(vRetResult.elementAt(i + 9)).length(); // isbn_number
	iCurChar += WI.getStrValue(vRetResult.elementAt(i + 9)).length(); // copies
	
	
	iCurLineNo += iCurChar/iCharPerLine + 1;//i have to keep one line in buffer.
	if( (iLinesPerPg - iCurLineNo) <5) {
		++iPageCount;
		bolPageBreak = true;
	}
	else
		bolPageBreak = false;
	%>
	
	<tr> 
	  <td height="10" width="15%"><%=WI.getStrValue(vRetResult.elementAt(i))%></td>
	  <td height="10" width="25%"><%=WI.getStrValue(vRetResult.elementAt(i+4))%></td>
	  <td height="10" width="17%"><%=WI.getStrValue(vRetResult.elementAt(i+7))%></td>
	  <td height="10" width="19%"><%=WI.getStrValue(vRetResult.elementAt(i+8))%></td>
	  <td height="10" width="7%"><%=WI.getStrValue(vRetResult.elementAt(i+9))%></td>
	  <td height="10" width="10%"><%=WI.getStrValue(vRetResult.elementAt(i+9))%></td>
	  <td height="10" width="7%"><%=WI.getStrValue(vRetResult.elementAt(i+9))%></td>
	</tr>
	
<%if(!bolPageBreak){%>
    <tr> 
      <td height="10" colspan="7">&nbsp;</td>
    </tr>
<%}else {//insert heading
//System.out.println("Page Count : "+iPageCount +" Line Number : "+iCurLineNo);
iCurLineNo = 0;	iCurChar = 0; bolPageBreak = false;%>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
	<DIV style="page-break-before:always" >&nbsp;</DIV>

    <tr> 
      <td height="10" colspan="7">	  
		<table width="100%" border="0" cellspacing="0" cellpadding="0">		
		<tr >
		  <td height="25"><div align="center"><font size="2">
		  <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font><br>
			<font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%>						
			</font></div></td>
		</tr>
		</table>
		
	  <table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
		  <td height="15"><%=WI.getTodaysDateTime()%></td>
		  <td align="right">Page <%=iPageCount%>&nbsp;&nbsp;</td>
		</tr>
		<tr> 
		  <td height="20" colspan="2"><hr size="1"></td>
		</tr>
	  </table>
	  
	  <table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
		  <td height="10" width="15%">Call No.</td>
		  <td height="10" width="25%">Book Title</td>
		  <td height="10" width="17%">Publication Place</td>
		  <td height="10" width="19%">Publisher</td>
		  <td height="10" width="7%">Copyright</td>
		  <td height="10" width="10%">ISBN No.</td>
		  <td height="10" width="7%">Copies</td>
		</tr>
	  </table>
	  
	  </td>
    </tr>
<%}//only if page break

}//end of for loop.%>
  </table>

</body>
</html>
<%
dbOP.cleanUP();
%>
