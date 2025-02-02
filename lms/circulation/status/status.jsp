<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction() {
	document.form_.page_action.value = "1";
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	var Year = document.form_.usage_year.value;
	if(Year.length <4) {
		alert("Please enter Year value.");
		return;
	}
	document.form_.submit();
}
function focusID() {
	document.form_.ACCESSION_NO.focus();
}
function OpenSearch() {
	var pgLoc = "../../search/search_simple.jsp?opner_info=form_.ACCESSION_NO";
	var win=window.open(pgLoc,"PrintWindow",'width=950,height=650,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateStatus(strBookIndex) {
	var pgLoc = "./update_status.jsp?book_index="+strBookIndex+"&accession_number="+
		escape(document.form_.ACCESSION_NO.value);
	var win=window.open(pgLoc,"PrintWindow",'width=650,height=550,top=30,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<%@ page language="java" import="utility.*,lms.LmsUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Circulation-COLLECTION STATUS","status.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Circulation","COLLECTION STATUS",request.getRemoteAddr(),
														"status.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	String strTemp         = null;
	LmsUtil lUtil          = new LmsUtil();
	lms.CatalogLibCol lCol = new lms.CatalogLibCol();
	Vector vBookInfo       = null;
	Vector vBookIssueInfo  = new Vector();
	String[] astrBookStat  = null;
	String strBookIndex    = null;//get from accession number. 
	int iNoOfCopy          = 0;
	
	if(WI.fillTextValue("ACCESSION_NO").length() > 0) {
		strBookIndex = dbOP.mapBookIDToBookIndex(WI.fillTextValue("ACCESSION_NO"));
		if(strBookIndex == null) 
			strErrMsg = "Accession/Barcode : "+WI.fillTextValue("ACCESSION_NO")+" does not exist.";
		else {
			//I have to get book information.
			vBookInfo = lCol.operateOnBasicEntry(dbOP, request, 3);
			if(vBookInfo == null) 
				strErrMsg = lCol.getErrMsg();
			else {
				//get copy information.
				Vector vTemp = lUtil.getNoOfCopy(dbOP, strBookIndex);
				if(vTemp != null)
					iNoOfCopy = vTemp.size();
					
				vBookIssueInfo = lUtil.getBookIssueInfo(dbOP, strBookIndex);
				if(vBookIssueInfo == null)
					vBookIssueInfo = new Vector();
				
			}
		}
	}
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		astrBookStat = lUtil.getOrUpdateBookStatus(dbOP, strBookIndex, WI.fillTextValue("book_status"));
		if(astrBookStat == null) {
			strErrMsg = lUtil.getErrMsg();
		}
		else {
			strErrMsg = "Book status successfully changed.";
		}
	}
	
if(astrBookStat == null && strBookIndex != null) {//I have to get current book status.
	astrBookStat = lUtil.getOrUpdateBookStatus(dbOP, strBookIndex,null);
	if(astrBookStat == null) 
		strErrMsg = lUtil.getErrMsg();
}

boolean bolEditAllowed = true; 
if(astrBookStat == null || astrBookStat[0].compareTo("2") == 0) 
	bolEditAllowed = false;
	
	
Vector vCirculationDtls = null;
if(strBookIndex != null) {
	lms.CirculationReport cirReport = new lms.CirculationReport();
	vCirculationDtls = cirReport.bookUsageSummary(dbOP, strBookIndex, WI.fillTextValue("show_copy").equals("1"), request);
	if(vCirculationDtls == null)
		strErrMsg = cirReport.getErrMsg();
}

%>
<body bgcolor="#D0E19D" onLoad="focusID();">
<form action="./status.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#77A251"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CIRCULATION : COLLECTION STATUS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"> &nbsp;&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font> </td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="20%" height="25"><font size="1">Accession / Barcode No. </font></td>
      <td width="21%"><input type="text" name="ACCESSION_NO" value="<%=WI.fillTextValue("ACCESSION_NO")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="20" maxlength="32"></td>
      <td width="15%"><a href="javascript:OpenSearch();"><img src="../../images/search_book_circulation.gif" border="0"></a></td>
      <td width="44%"><input type="image" src="../../images/form_proceed.gif" onClick="ReloadPage();"></td>
    </tr>
    <tr>
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%
if(vBookInfo != null) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"><font size="1">Accession/Barcode : <strong><%=WI.fillTextValue("accession_no")%> 
        ::: <%=(String)vBookInfo.elementAt(36)%></strong></font></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="47%" height="25"><font size="1">Title : <strong><%=(String)vBookInfo.elementAt(1)%> <%=WI.getStrValue((String)vBookInfo.elementAt(2),"::: ","","")%></strong></font></td>
      <td width="53%"><font size="1">Library Location : <strong><%=(String)vBookInfo.elementAt(41)%></strong></font></td>
    </tr>
    <tr> 
      <td height="25"><font size="1">Author :<strong> <%=(String)vBookInfo.elementAt(11)%></strong></font></td>
      <td><font size="1">Collection Location : <strong><%=(String)vBookInfo.elementAt(42)%></strong></font></td>
    </tr>
    <tr> 
      <td height="25"><font size="1">Material Type : <strong><%=(String)vBookInfo.elementAt(38)%></strong></font></td>
      <td><font size="1">Current Status : 
        <%
//if issued, do not edit.
if(!bolEditAllowed) {%>
        <strong><%=astrBookStat[1]%></strong> 
        <%}else{%>
		<b><%=astrBookStat[1]%></b>
		<!--<a href="javascript:UpdateStatus(<%=strBookIndex%>);">
		<img src="../../images/update_rec.gif" border="1"></a>-->
<!--
        <select name="book_status" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 14;">
          <%=dbOP.loadCombo("BS_REF_INDEX","STATUS"," from LMS_BOOK_STAT_REF WHERE BS_REF_INDEX <> 2 order by BS_REF_INDEX asc",
		  	astrBookStat[0], false)%> 
        </select>
-->
        <%}%>
        </font></td>
    </tr>
    <tr> 
      <td height="25"><font size="1">Edition : <strong><%=WI.getStrValue(vBookInfo.elementAt(5))%> <%=WI.getStrValue((String)vBookInfo.elementAt(6),"::: ","","")%></strong></font></td>
      <td><font size="1">No. of Copies : <strong><%=iNoOfCopy%></strong></font></td>
    </tr>
    <tr> 
      <td height="25"><font size="1">Call No. : <strong><%=(String)vBookInfo.elementAt(30)%></strong></font></td>
      <td valign="top">
			<%
			if(astrBookStat[0].equals("2") && vBookIssueInfo.size() > 0){
			%>
				
				<div style=" width:350px; position: absolute; top:10; right:10; border: solid 2px #000000; background-color:#CCCCCC">
				<table width="100%" align="right" cellpadding="0" cellspacing="0">
					<tr>
					   <td colspan="2" class="thinborderBOTTOM" style="font-size:9px" align="center"><strong>ISSUE INFORMATION</strong></td>
					   </tr>
					<tr>
						<td width="42%" class="thinborderBOTTOM" style="font-size:9px">ISSUED TO</td>
						<%
						strTemp = WebInterface.formatName((String)vBookIssueInfo.elementAt(6),(String)vBookIssueInfo.elementAt(7),(String)vBookIssueInfo.elementAt(8),4);
						
						strTemp += WI.getStrValue((String)vBookIssueInfo.elementAt(5), " ( ", " ) " , "");
						%>
						<td width="58%" class="thinborderBOTTOM" style="font-size:9px"><%=strTemp%></td>
					</tr>	
					<tr>
						<td style="font-size:9px" class="thinborderBOTTOM">ISSUED DATE & TIME</td>
						<%
						strTemp = (String)vBookIssueInfo.elementAt(9);
						strTemp += WI.getStrValue((String)vBookIssueInfo.elementAt(10), " @ ", "" , "");
						%>
						<td style="font-size:9px" class="thinborderBOTTOM"><%=strTemp%></td>
					</tr>	
					<tr>
						<td style="font-size:9px">DUE DATE & TIME</td>
						<%
						strTemp = (String)vBookIssueInfo.elementAt(11);
						strTemp += WI.getStrValue((String)vBookIssueInfo.elementAt(12), " @ ", "" , "");
						%>
						<td style="font-size:9px"><%=strTemp%></td>
					</tr>					
				</table>			
				</div>
			<%}else{%>&nbsp;<%}%>
		</td>
    </tr>
    <tr> 
      <td height="19" colspan="2"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25" colspan="2">Collection Usage Detail for Year : 
<%
strTemp = WI.fillTextValue("usage_year");
if(strTemp.length() == 0) {
	strTemp = WI.getTodaysDate();
	strTemp = strTemp.substring(0,4);
}%>
		<input type="text" name="usage_year" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10">	  
	  &nbsp;&nbsp;  &nbsp;&nbsp;&nbsp;	  
<%
strTemp = WI.fillTextValue("show_copy");
if(strTemp.equals("1") || request.getParameter("page_action") == null)
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="checkbox" name="show_copy" value="1" <%=strTemp%>> Include Copy Information
	  &nbsp;&nbsp;  &nbsp;&nbsp;&nbsp;	  
	  <input type="button" name="_" value="Reload Page" onClick="ReloadPage();">
	  
	  </td>
    </tr>
<%if(vCirculationDtls != null && vCirculationDtls.size() > 0) {%>
    <tr>
      <td height="25" colspan="2" style="font-weight:bold; font-size:11px;">Total No of Issue : <%=vCirculationDtls.size()/5%></td>
    </tr>
    <tr>
      <td height="25" colspan="2">
	  <table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
	  	<tr style="font-weight:bold">
			<td height="21" class="thinborder" width="15%" align="center">ID</td>
			<td class="thinborder" width="30%" align="center">Name</td>
			<td class="thinborder" width="15%" align="center">Issued Date</td>
			<td class="thinborder" width="15%" align="center">Returned Date</td>
			<td class="thinborder">&nbsp;Accession NO</td>
		</tr>
	  	<%for(int i = 0; i < vCirculationDtls.size(); i+= 5){%>
			<tr>
			  <td height="21" class="thinborder">&nbsp;<%=vCirculationDtls.elementAt(i + 1)%></td>
			  <td class="thinborder">&nbsp;<%=vCirculationDtls.elementAt(i + 2)%></td>
			  <td class="thinborder">&nbsp;<%=vCirculationDtls.elementAt(i + 3)%></td>
			  <td class="thinborder">&nbsp;<%=WI.getStrValue(vCirculationDtls.elementAt(i + 4))%></td>
			  <td class="thinborder">&nbsp;<%=vCirculationDtls.elementAt(i)%></td>
		  </tr>
	    <%}%>
	  </table>	  </td>
    </tr>
<%}//if(vCirculationDtls != null && vCirculationDtls.size() > 0) {%>	
  </table>
 <%}//only if vBookInfo. is not null
 %>
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>