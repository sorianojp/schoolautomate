<%@ page language="java" import="utility.*, docTracking.deped.DocumentTracking, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Pending Documents</title>
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript">
	
	function viewTracking(strBarcodeID){
		location = "./document_tracking.jsp?is_forwarded=1&barcode_id="+strBarcodeID;
	}

	function PrintPg() {
		document.form_.print_pg.value = '1';
		document.form_.search_.value = '1';
		document.form_.submit();
	}
	function loadSearchDept() {
		var objCOA=document.getElementById("load_search_dept");
 		var objCollegeInput = document.form_.search_college[document.form_.search_college.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=search_dept&all=1";
		this.processRequest(strURL);
	}
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here..
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"DOCUMENT TRACKING","pending_documents.jsp");
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
	else
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING-REPORTS"),"0"));
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	int iPendingDocuments = 0;	
	DocumentTracking dt = new DocumentTracking();
	Vector vRetResult = null;
	if(WI.fillTextValue("search_").length() > 0) {
		vRetResult = dt.getPendingDocuments(dbOP, request);
		if(vRetResult == null)
			strErrMsg = dt.getErrMsg();
		else
			iPendingDocuments = vRetResult.size()/20;
	}
	boolean bolIsPrint = WI.fillTextValue("print_pg").equals("1");


	String strReportName = null;
	if(WI.fillTextValue("search_college").length() > 0) {
		strTemp = "select c_code from college where c_index = "+WI.fillTextValue("search_college");
		strTemp = dbOP.getResultOfAQuery(strTemp, 0) ;
		if(strTemp != null)
			strReportName = " For: "+strTemp;
	}
	if(WI.fillTextValue("search_dept").length() > 0) {
		strTemp = "select d_code from department where d_index = "+WI.fillTextValue("search_dept");
		strTemp = dbOP.getResultOfAQuery(strTemp, 0) ;
		if(strTemp != null) {
			if(strReportName == null)
				strReportName = " For: "+strTemp;
			else	
				strReportName += " - "+strTemp;
		}
	}
	
	boolean bolIsAuthRestricted = dt.bolIsUserRestricted(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%>
<body onload="<%if(bolIsPrint){%>window.print();<%}%>">
<form name="form_" action="pending_documents.jsp" method="post">
<%
int iDefVal = 30;
if(!bolIsPrint){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr style="font-weight:bold"> 
			<td height="25" align="center" colspan="3" class="thinborderBOTTOM"> :::: PENDING DOCUMENT ::::</td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>

		<tr>
			<td height="25">&nbsp;</td>
		  	<td>
				<%if(WI.fillTextValue("search_").length() > 0) {%>
					Pending Documents: <strong><%=iPendingDocuments%></strong>
				<%}%>
			</td>
		    <td style="font-size:14px; font-weight:bold; color:#FF0000;">
			<%if(bolIsAuthRestricted) {%>
				Authentication is Restricted
			<%}%>
			
			</td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td colspan="2">Filter Option: 
				<%
					String strCollegeCon = WI.fillTextValue("search_college");
				%>
		  <select name="search_college" onChange="loadSearchDept();">
			<option value="">ALL</option>
			<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0 order by c_name", strCollegeCon, false)%> 
          </select>
			- 
		  <label id="load_search_dept">
			<select name="search_dept">
				<option value="">ALL</option>
			<%if (strCollegeCon.length() == 0){%>
				<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null) order by d_name", WI.fillTextValue("search_dept"), false)%> 
			<%}else{%>
				<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeCon + " order by d_name ", WI.fillTextValue("search_dept"), false)%> 
			 <%}%>
			</select>
		  </label>		  </td>
	  </tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td colspan="2">Barcode ID: 
			<input type="text" name="barcode_id" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onblur="style.backgroundColor='white'" size="32" maxlength="32" value="<%=WI.fillTextValue("barcode_id")%>"/>		  </td>
	  </tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td width="51%">Sort By: 
<%
strTemp = WI.fillTextValue("sort_by_");
if(strTemp.length() == 0)
	strTemp = "doc";
if(strTemp.startsWith("doc"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		  <input type="radio" value="doc_deped_transaction.create_date" name="sort_by_" <%=strErrMsg%> onchange="document.form_.print_pg.value='';document.form_.submit();"> Transaction Date 
<%
if(strTemp.startsWith("c_code"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		  <input type="radio" value="c_code,d_code" name="sort_by_" <%=strErrMsg%> onchange="document.form_.print_pg.value='';document.form_.submit();"> Department		  
		  
<%
if(strTemp.startsWith("receive_time"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
		  <input type="radio" value="receive_time" name="sort_by_" <%=strErrMsg%> onchange="document.form_.print_pg.value='';document.form_.submit();"> Duration		  </td>
	      <td width="46%" style="font-size:11px;">
		  
		  <select name="rows_per_pg">
<%
if(WI.fillTextValue("rows_per_pg").length() > 0) 
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i = 20; i < 65; ++i) {
	if(iDefVal == i) 
		strTemp = "selected";
	else	
		strTemp = "";
%>
	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>		  
		  </select>
		  
		  Rows Per Page &nbsp;&nbsp;&nbsp;
		  <a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0" /></a>
		  Print Result </td>
	  </tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td><a href="#"><img src="../../images/form_proceed.gif" border="0" onclick="document.form_.print_pg.value='';document.form_.search_.value='1';document.form_.submit();"></a>
				<font size="1">Click to search</font></td>
		  <td style="font-size:11px;">&nbsp;</td>
	  </tr>
		<tr>
			<td height="15">&nbsp;</td>
		  	<td colspan="2">&nbsp;</td>
		</tr>
	</table>
<%}%>	
<%if(vRetResult != null && vRetResult.size() > 0){
int iCurRow = 0; 
int iCurPage = 0;
int iTotalPages = vRetResult.size()/24;
iCurRow = iTotalPages/iDefVal;
if(iTotalPages % iDefVal > 0)
	++ iCurRow;
iTotalPages = iCurRow;
int iCount =0; int iTemp = 0;
String strTime = WI.getTodaysDateTime();

for(int i = 0; i < vRetResult.size();) {
iCurRow = 0;
	if(i > 0) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>		
<%}%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" colspan="2">
				<div align="center"><strong>::: LIST OF PENDING TRANSACTION(S) IN RECORD <%=WI.getStrValue(strReportName)%> ::: </strong></div></td>
		</tr>
		<tr valign="top">
		  <td width="50%" height="20" style="font-size:9px;">Date and Time Printed: <%=strTime%></td>
	      <td width="50%" align="right" style="font-size:9px;">Page <%=++iCurPage%> of <%=iTotalPages%></td>
	  </tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr style="font-weight:bold" align="center">
		  <td width="4%" class="thinborder">Count</td>
			<td height="25" width="21%" class="thinborder"><strong>Origin/Owner</strong></td>
			<td width="15%" class="thinborder"><strong>Category</strong></td>
			<td width="10%" class="thinborder"><strong>Barcode ID</strong></td>
			<td width="18%" class="thinborder"><strong>Responsible Personnel </strong></td>
			<td width="10%" class="thinborder"><strong>Transaction Date </strong></td>
			<td width="10%" class="thinborder"><strong>Currently in</strong></td>
            <td width="12%" class="thinborder">Duration</td>
          <%if(!bolIsPrint){%>
			<td width="5%" align="center" class="thinborder"><strong>View</strong></td>
<%}%>
		</tr>
	<%
	for(; i < vRetResult.size(); i += 24){
	++iCurRow;
	if(iCurRow > iDefVal)
		break;
	%>
		<tr>
		  <td class="thinborder"><%=++iCount%>.</td>
			<td height="22" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+13)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+16)%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6));
				strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+8));
				
				if(strTemp.length() > 0 && strErrMsg.length() > 0)
					strTemp += "/ ";
				strTemp += strErrMsg;
			%>
		    <td class="thinborder">&nbsp;<%=strTemp%></td>
            <td class="thinborder">
			<%if(vRetResult.elementAt(i + 20) == null) {%>&nbsp;<%}else{
			iTemp = Integer.parseInt((String)vRetResult.elementAt(i + 20));
			if(iTemp == 0) 
				strTemp = "";
			else if(iTemp < 5)
				strTemp = "<img src='./yellow.jpg'>";
			else if(iTemp < 10)
				strTemp = "<img src='./blue.jpg'>";
			else if(iTemp < 15)
				strTemp = "<img src='./orange.jpg'>";
			else
				strTemp = "<img src='./red.jpg'>";
			%>
				<%=vRetResult.elementAt(i + 21)%><%=strTemp%>
			<%}%>
			</td>
          <%if(!bolIsPrint){%>
			<td align="center" class="thinborder"><a href="javascript:viewTracking('<%=(String)vRetResult.elementAt(i+5)%>')"><img src="../../images/view.gif" border="0" /></a></td>
		  <%}%>
		</tr>
	<%}%>
	</table>
<%}
}%>
<input type="hidden" name="print_pg" />	
<input type="hidden" name="search_" />	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>