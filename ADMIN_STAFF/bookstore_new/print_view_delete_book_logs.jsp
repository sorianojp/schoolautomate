<%@ page language="java" import="utility.*, citbookstore.BookLogs,citbookstore.BookManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>View/Delete Book Logs</title>
</head>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
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
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=20400&query_con="+vCondition+"&onchange="+onChange+"&sel_name="+selName+"&table_name="+tableName+"&fields="+fields+"&header="+header+"&header_value="+headerValue;
	
		this.processRequest(strURL);
	}
	
	function DeleteLog(strLogIndex, strQuantity){
		if(!confirm("Are you sure you want to delete this log?"))
			return;
		document.form_.search_logs.value = "1";
		document.form_.delete_log.value = strLogIndex;
		document.form_.quantity.value = strQuantity;
		document.form_.submit();
	}
	
	function GoBack(){
		location = "./book_supply_log_main.jsp";
	}
	
	function SearchLogs(){
		document.form_.search_logs.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function PrintPg(){
	var PageLoc = "";
	
	if(document.form_.date_type.value == '2'){
		PageLoc = "print_view_update_book_quantity.jsp?book_type="+document.form_.book_type.value+"&book_catg="+document.form_.book_catg.value+
			"&classification="+document.form_.classification.value+"&date_type="+document.form_.date_type.value+"&date_fr="+document.form_.date_fr.value+
			"&date_to="+document.form_.date_to.value+"&for_printing=1";
	}else{
		PageLoc = "print_view_update_book_quantity.jsp?book_type="+document.form_.book_type.value+"&book_catg="+document.form_.book_catg.value+
			"&classification="+document.form_.classification.value+"&date_type="+document.form_.date_type.value+"&date_fr="+document.form_.date_fr.value+
			"&for_printing=1";
	}
	
			
		var win=window.open(PageLoc,"PrintPg",'width=1000,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-BOOK MANAGEMENT","view_delete_book_logs.jsp");
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-BOOK MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		//iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"Book Title","Author","Item Code","Log Date"};
	String[] astrSortByVal     = {"book_title","author","item_code","log_date"};
	
	int iSearchResult = 0;
	BookLogs bl = new BookLogs();
	BookManagement bm = new BookManagement();
	
	if(WI.fillTextValue("delete_log").length() > 0){
		if(bl.operateOnBookLogs(dbOP, request, 0) == null)
			strErrMsg = bl.getErrMsg();
		else
			strErrMsg = "Book log successfully deleted.";
	}
	
	Vector vRetResult = null;
	
	
		vRetResult = bl.operateOnBookLogs(dbOP, request, 4);
		if(vRetResult == null){
			if(WI.fillTextValue("delete_log").length() == 0)
				strErrMsg = bl.getErrMsg();
		}
		else
			iSearchResult = bl.getSearchCount();
	
%>
<body onload="window.print();">
  

<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
	<tr><td align="center"><font size="3"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td></tr>
	<tr><td align="center">History Supply Log Report<br /> <br /></td></tr>
	<tr><td align="center"><%=WI.getStrValue(WI.fillTextValue("date_fr"),"")%>
		<%if(WI.fillTextValue("date_to").length()>0){%> - 
	 	<%=WI.getStrValue(WI.fillTextValue("date_to"))%>
	 	<%}%><br /> <br /></td></tr>
</table>

<%
boolean bolIsPageBreak = false;
int iResultSize = 13;
int iLineCount = 0;
int iMaxLineCount = 30;	
int iCount = 0;	
int i = 0;
while(iResultSize <= vRetResult.size()){
iLineCount = 0;
%>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		
		<tr>
			<td height="18" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Item Code </strong></td>
			<td width="21%" align="center" class="thinborder"><strong>Book Title </strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Author</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Publisher</strong></td>
			<td width="8%"  align="center" class="thinborder"><strong>Log Qty</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Log Date</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Logged By</strong></td>		  	
		</tr>
	<%	for(; i < vRetResult.size();){
			iCount++;
			iLineCount++;		
			iResultSize += 13;	%>
		<tr>
			<td height="18" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+10), (String)vRetResult.elementAt(i+11), (String)vRetResult.elementAt(i+12), 4)%></td>			
		</tr>
		<%
			i+=13;
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
	
}%>
	
	
	

</body>
</html>
<%
dbOP.cleanUP();
%>