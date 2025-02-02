<%@ page language="java" import="utility.*, citbookstore.BookRequest,citbookstore.BookManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolIsCIT = strSchCode.startsWith("CIT");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Print Delivered Items History</title></head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	function loadClassification() {	
		var objCOA=document.getElementById("load_classification");
		var header = "All";
		var selName = "classification";
		var onChange = "";
		var tableName = "bed_level_info";
		var fields = "g_level,level_name";
		var headerValue = "";
		
		var vCondition = '';
		var vClassValue = document.form_.book_catg.value;
		if(vClassValue.length == 0)
			vCondition = ' where edu_level@0';
		else{
			if(vClassValue == '1')
				vCondition = '';
			else//if college
				vCondition = ' where edu_level@0';
		}
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20400&query_con="+vCondition+"&onchange="+onChange+"&sel_name="+selName+"&table_name="+tableName+"&fields="+fields+"&header="+header+"&header_value="+headerValue;
	
		this.processRequest(strURL);
	}

	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-PROPERTY MANAGEMENT","print_delivered_history.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-PROPERTY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		if(iAccessLevel == 0){
			response.sendRedirect("../../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	Vector vRetResult = new Vector();	
		
	BookRequest br = new BookRequest();
	
	vRetResult = br.viewDeliveredItems(dbOP, request);
	if(vRetResult == null)
		strErrMsg = br.getErrMsg();
			
%>
<body <%if(strErrMsg==null){%>onload="window.print();"<%}%>>

<%if(strErrMsg != null){%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="">
	<tr><td align="center"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>

</table>
<%}if(vRetResult != null && vRetResult.size() >0 && strErrMsg == null){%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="">
	<tr>
		<td height="25" colspan="2" align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%>
		<%if(bolIsCIT){%>
			<br />INSTRUCTIONAL MATERIALS DISTRIBUTION CENTER<br /><br />
		<%}%>
		
		</font></td>
	</tr>
	<tr><td height="20"><div align="center">HISTORY OF BOOKS DELIVERED</div></td></tr>	
</table>


<%
boolean bolIsPageBreak = false;
int iResultSize = 22;
int iLineCount = 0;
int iMaxLineCount = 30;	
int iCount = 0;	
int i = 0;
while(iResultSize <= vRetResult.size()){
iLineCount = 0;
%>		
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">						
			<tr>
				<td width="5%"  align="center" height="18" class="thinborder"><strong>Count</strong></td>
				<td width="18%" align="center" class="thinborder"><strong>Title</strong></td>
				<td width="13%" align="center" class="thinborder"><strong>Author</strong></td>
				<td width="14%" align="center" class="thinborder"><strong>Publisher</strong></td>				
				<td width="5%" align="center" class="thinborder"><strong>Qty</strong></td>								
				<td width="10%" align="center" class="thinborder"><strong>Approved By</strong></td>
				<td width="10%" align="center" class="thinborder"><strong>Approved Date</strong></td>	
				<td width="10%" align="center" class="thinborder"><strong>Delivered Date</strong></td>	
				<td width="15%" align="center" class="thinborder"><strong>Delivered To</strong></td>			
			</tr>
			
			<%			
			for(;i<vRetResult.size();){
			
			iCount++;
			iLineCount++;		
			iResultSize += 22;	
			
			%>
			<tr>	
				<td align="center" height="18" class="thinborder"><%=iCount%></td>
				<td align="" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
				<td align="" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+3),"N/A")%></td>
				<td align="" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+5),"N/A")%></td>				
				<td align="" class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>												
				<td align="" class="thinborder">
					<%=(String)vRetResult.elementAt(i+8)%>
					<%=(String)vRetResult.elementAt(i+9)%>.
					<%=(String)vRetResult.elementAt(i+10)%>
					
				</td>												
				<td align="" class="thinborder"><%=(String)vRetResult.elementAt(i+11)%></td>
				<td align="" class="thinborder"><%=(String)vRetResult.elementAt(i+21)%></td>
				
				<td align="" class="thinborder">
					<%=WI.getStrValue((String)vRetResult.elementAt(i+13))%>
					<%=WI.getStrValue((String)vRetResult.elementAt(i+14),"/ ","","")%>
					<%=WI.getStrValue((String)vRetResult.elementAt(i+16),"/ ","","")%>
					
				</td>	
			</tr>
			
			<%
			i+=22;
			if(iLineCount > iMaxLineCount){
				bolIsPageBreak = true;
				break;		
			}else
				bolIsPageBreak = false;	
			%>
			
			
			<%}%>		
			
						
	</table>
			
	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>
	
	
<%}if(iResultSize > vRetResult.size()){%>	
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
			<tr><td colspan="3" height="25">&nbsp;</td></tr>
			<tr>
				<td height="25" width="28%">FOR IMDC USE ONLY</td>
				<td width="36%" align="center"></td>
				<td width="36%" align="right">&nbsp;</td>
			</tr>
			
			<tr>
		  		<td height="20">&nbsp;</td>
		  		<td>&nbsp;</td>
		  		<td align="right">&nbsp;</td>
	  		</tr>
			<tr align="center">		  
		  		<td><table width="90%" cellpadding="0" cellspacing="0" border="0"><tr><td class="thinborderBOTTOM">&nbsp;</td></tr></table></td>
		  		<td height="25">&nbsp;</td>
		  		<td><table width="90%" cellpadding="0" cellspacing="0" border="0">
					<tr><td class="thinborderBOTTOM" align="center">&nbsp;
					<%=request.getSession(false).getAttribute("first_name")%> <%=WI.getTodaysDateTime()%></td></tr></table></td>
	  		</tr>
			<tr align="center">
		  		<td>APPROVED BY/DATE </td>
		  		<td>&nbsp;</td>		  
		  		<td>VERIFIED BY/DATE</td>
	  		</tr>
	</table>
		
<%
	}//end if(iResultSize > vRetResult.size())
}//end of vRetResult!=null%>

</body>
</html>
<%
dbOP.cleanUP();
%>
