<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg() {
	var pgLoc = "./my_collection_print.jsp";
	var win=window.open(pgLoc,"EditWindow",'width=924,height=600,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ClearEntry() {
	document.form_.accession_no.value = "";
	document.form_.my_note.value ="";
}
function ViewDetail(strAccessionNo) {
//popup window here. 
	var pgLoc = "../search/collection_details.jsp?accession_no="+escape(strAccessionNo);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=600,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function Reserve(strAccessionNo) {

}
function PageAction(strAction, strIndex, strBookIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strIndex;
	document.form_.info_book_index.value  = strBookIndex;
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../search/search_simple.jsp?opner_info=form_.accession_no";
	var win=window.open(pgLoc,"PrintWindow",'width=950,height=650,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//reload page if accession number is changed.
function OnBlurAccessionNo() {
	if(document.form_.accession_no_old.value != document.form_.accession_no.value)
		document.form_.submit();
}
function CopyAccessionNo(strAccessionNo) {
	document.form_.accession_no.value = strAccessionNo;
}
</script>
<body bgcolor="#F2DFD2">
<%@ page language="java" import="utility.*,lms.BookReservation,java.util.Vector" %>
<%
/**
This is called in myhome, there is another page for book reservation by circulation
In this page, user can't reserve book if no of books already reserved is > max allowed reservation
**/
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;
	String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");

	if(strUserIndex == null) {
		//do not proceed - proceed to login.
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
BookReservation bRes = new BookReservation();
Vector vRetResult = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(strTemp.equals("0")){//remove reservation
		if(bRes.deleteReservation(dbOP, request))
			strErrMsg = "Reservation information successfully removed.";
		else	
			strErrMsg = bRes.getErrMsg();
	}
	else {
		if(bRes.reserveABook(dbOP, request, strUserIndex))
			strErrMsg = "Book is reserved.";
		else	
			strErrMsg = bRes.getErrMsg();
	}
}
//view all. 
boolean bolResAllowed = false;
int iMaxRes = 0; int iReserved = 0; int iCanBeReserved = 0; 
vRetResult = bRes.getReservationInfo(dbOP, strUserIndex, null,true);
if(vRetResult == null)
	strErrMsg = bRes.getErrMsg();
else {
	iMaxRes    = ((Integer)vRetResult.remove(0)).intValue();
	iReserved  = ((Integer)vRetResult.remove(0)).intValue();
	vRetResult = (Vector)vRetResult.remove(1);
	iCanBeReserved = iMaxRes - iReserved;
	if(iCanBeReserved < 1)
		iCanBeReserved = 0;
}
if(iCanBeReserved > 0)
	bolResAllowed = true;
	
///find out if person is in circulation.. 
boolean bolIsCirculation = false; 
    java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
    if ( (svhAuth.size() == 1 && svhAuth.get("ALL") != null) || //super user or having only cataloging.
         svhAuth.get("LIB_Cataloging".toUpperCase()) != null)
      bolIsCirculation = true; 
	  
///this vector gives reservation information.
Vector vReservationInfo = null;
if(WI.fillTextValue("accession_no").length() > 0) { 
	vReservationInfo = bRes.getReservationInfo(dbOP, WI.fillTextValue("accession_no"), false, strUserIndex);
	if(vReservationInfo == null)
		strErrMsg = bRes.getErrMsg();
	else if(strErrMsg == null && vReservationInfo.elementAt(1) != null)
		strErrMsg = (String)vReservationInfo.elementAt(1);
}
%>
<form action="./reserve_book.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          BOOK RESERVATION PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  Patron Name : <strong><%=(String)request.getSession(false).getAttribute("first_name")%></strong>
	  &nbsp;&nbsp; 
	   ID: <strong><%=(String)request.getSession(false).getAttribute("userId")%></strong>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" class="thinborderALL"><strong><font size="2">Maximum Reservation : <%=iMaxRes%>&nbsp;&nbsp;&nbsp; Total Reserved : <%=iReserved%>&nbsp;&nbsp;&nbsp; Can be reserved : <%=iCanBeReserved%></font></strong></td>
    </tr>
<%
if(bolIsCirculation){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><font color="#FF0000" size="2">	  User has already exceeded Reservation limit!!! <b> 
        <input type="checkbox" name="over_ride" value="1">
      Check here to  exceed reservation limit</b></font></td>
    </tr>
<%bolResAllowed = true;}
if(bolResAllowed){%>
	<tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%">Accession No</td>
      <td width="80%"><input name="accession_no" type="text" size="24" value="<%=WI.fillTextValue("accession_no")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="javascript:OnBlurAccessionNo();style.backgroundColor='white'">
      <a href="javascript:OpenSearch();"><img src="../images/search_recommend.gif" border="0"></a>
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <a href="javascript:document.form_.submit();">Show Reservation Information </a></td>
    </tr>
<%//System.out.println(vReservationInfo);
if(vReservationInfo != null &&  vReservationInfo.elementAt(1) == null) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Reservation Info(Others)
	  <table width="95%" class="thinborder" cellpadding="0" cellspacing="0" border="0">
	  	<tr bgcolor="#FFFFCC">
			<td width="17%" style="font-size:10px" class="thinborder">Accession No</td>
			<td width="23%" style="font-size:10px" class="thinborder">Book Issue Info</td>
			<td width="60%" style="font-size:10px" class="thinborder">No of reservation</td>
		</tr>
<%for(int i =2; i < vReservationInfo.size(); i += 6){%>
	  	<tr>
	  	  <td style="font-size:10px" class="thinborder">&nbsp;
		  <a href="javascript:CopyAccessionNo('<%=(String)vReservationInfo.elementAt(i + 1)%>');">
		  <%=(String)vReservationInfo.elementAt(i + 1)%></a></td>
	  	  <td style="font-size:10px" class="thinborder">&nbsp;<%=WI.getStrValue(vReservationInfo.elementAt(i + 2),"&nbsp;")%></td>
	  	  <td style="font-size:10px" class="thinborder">&nbsp;<%=(String)vReservationInfo.elementAt(i + 3)%></td>
	  	  </tr>
<%}%>
	  </table>
	  
	  
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Reservation Note</td>
      <td><input name="my_note" type="text" size="80" maxlength="256" value="<%=WI.fillTextValue("my_note")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Reservation Date </td>
      <td>
<%
strTemp = WI.fillTextValue("res_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>	  <input name="res_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%if(bolIsCirculation){%>
	    <a href="javascript:show_calendar('form_.res_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a>
<%}%>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>New Expire Date </td>
      <td>
<%
strTemp = WI.fillTextValue("expire_date");
if(strTemp.length() == 0) 
	strTemp = ConversionTable.addMMDDYYYY(WI.getTodaysDate(1),7,0,0);
%>
        <input name="expire_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<%if(bolIsCirculation){%>
	   <a href="javascript:show_calendar('form_.expire_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a>
<%}%>	   </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Reservation Type </td>
      <td>
<%
strTemp = WI.fillTextValue("res_type");
if(strTemp.equals("0") || strTemp.length() == 0) 
	strTemp = " checked";
else	
	strTemp = "";
%>	  <input name="res_type" type="radio" value="0"<%=strTemp%>>
      Any Copy 
<%
if(strTemp.length() == 0) 
	strTemp = " checked";
else	
	strTemp = "";
%>
        <input name="res_type" type="radio" value="1"<%=strTemp%>>
      One Copy </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Reservation Priority </td>
      <td>
<%if(bolIsCirculation)
	strTemp = "";
  else	
	strTemp = "disabled";
%>	  <select name="res_priority" <%=strTemp%>>
	  <option value="1">1</option>
<%
strTemp = WI.fillTextValue("res_priority");
if(strTemp.length() == 0) 
	strTemp = "10";
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>		<option value="2"<%=strErrMsg%>>2</option>	  
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>		<option value="3"<%=strErrMsg%>>3</option>	  
<%
if(strTemp.equals("4"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>		<option value="4"<%=strErrMsg%>>4</option>	  
<%
if(strTemp.equals("5"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>		<option value="5"<%=strErrMsg%>>5</option>	  
<%
if(strTemp.equals("6"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>		<option value="6"<%=strErrMsg%>>6</option>	  
<%
if(strTemp.equals("7"))
	strErrMsg =  "selected";
else	
	strErrMsg = "";
%>		<option value="7"<%=strErrMsg%>>7</option>	  
<%
if(strTemp.equals("8"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>		<option value="8"<%=strErrMsg%>>8</option>	  
<%
if(strTemp.equals("9"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>		<option value="9"<%=strErrMsg%>>9</option>	  
<%
if(strTemp.equals("10"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>		<option value="10"<%=strErrMsg%>>10</option>	  
	  </select> 
      (Priority 1 is highest and 10 is lowest) </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp; <a href='javascript:PageAction("1","","");'><img src="../images/add.gif" border="0"></a> 
        <font size="1">Click to add the book to collection list.</font>
		<a href='javascript:ClearEntry();'><img src="../../images/clear.gif" border="1"></a> 
		<font size="1">Click to clear entries.</font>
<%if(vRetResult != null){%>
		<a href='javascript:PrintPg();'><img src="../images/print_recommend.gif" border="0"></a> 
        <font size="1">Click to print collection list.</font>
<%}

}///only if bolResAllowed
%>		
        </td>
    </tr>
<%}//if vReservationInfo is not null.%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr style="font-size:14px; font-weight:bold; text-align:center">
      <td width="15%" height="25" class="thinborder" style="font-size:10px;">ACCESSION NO. / BARCODE</td>
      <td width="30%" class="thinborder" style="font-size:10px;">:::TITLE ::: <br> SUB TITILE</td>
      <td width="10%" class="thinborder" style="font-size:10px;">RES. DATE </td>
      <td width="6%" class="thinborder" style="font-size:10px;">RES. STATUS </td>
      <td width="21%" class="thinborder" style="font-size:10px;">RESERVATION NOTE</td>
      <td width="6%" class="thinborder" style="font-size:10px;">REMOVE</td>
      <td width="6%" class="thinborder" style="font-size:10px;">Book Detail</td>
      <td width="6%" class="thinborder" style="font-size:10px;">My Collection </td>
    </tr>
    <%String[] astrConvertResType = {"Any copy","One Copy"};
for(int i = 0; i < vRetResult.size(); i += 13){%>
    <tr>
      <td height="25" valign="top" class="thinborder" style="font-size:10px;"><%=(String)vRetResult.elementAt(i+7)%>/ <%=(String)vRetResult.elementAt(i + 12)%></td>
      <td class="thinborder" valign="top" style="font-size:10px;">&nbsp;:::<%=(String)vRetResult.elementAt(i + 8)%>::: <br>
        &nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 9))%></td>
      <td class="thinborder" valign="top" style="font-size:10px;">
	  <%=(String)vRetResult.elementAt(i + 5)%> to <br> <%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder" valign="top" style="font-size:10px;"><%=(String)vRetResult.elementAt(i + 3)%><br>
	  (<%=astrConvertResType[Integer.parseInt((String)vRetResult.elementAt(i + 2))]%>)</td>
      <td class="thinborder" valign="top" style="font-size:10px;"><%=WI.getStrValue(vRetResult.elementAt(i + 4),"&nbsp;")%></td>
      <td class="thinborder" align="center"><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i + 1)%>");'><img src="../images/delete_recommend.gif" border="0"></a></td>
      <td class="thinborder" align="center"><a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i + 2)%>");'><img src="../images/view_collection_dtls.gif" border="0"></a>      </td>
      <td class="thinborder" align="center"><a href='javascript:MyCollection("<%=(String)vRetResult.elementAt(i + 7)%>");'><img src="../images/my_collection.gif" border="0"></a></td>
    </tr>
    <%}%>
  </table>
<%}//end of vRetResult not null.%>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="info_book_index">
<input type="hidden" name="accession_no_old" value="<%=WI.fillTextValue("accession_no")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>