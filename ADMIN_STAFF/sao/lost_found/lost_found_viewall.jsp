<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.LostFound"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form1_.case_type_name.value = document.form1_.case_type[document.form1_.case_type.selectedIndex].text;
	document.form1_.item_name.value = document.form1_.item_index[document.form1_.item_index.selectedIndex].text;
	
	document.form1_.pring_pg.value='';
	document.form1_.submit();

}
function DeleteRecord(strInfoIndex) {
	document.form1_.page_action.value = "0";
	document.form1_.info_index.value = strInfoIndex;

	document.form1_.pring_pg.value='';
	document.form1_.submit();
}
function EditInfo(strRefNo) {
	
	if(document.form1_.opner_info.value.length !=0){
	<%if(WI.fillTextValue("opner_info").length() > 0){%>
		window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strRefNo;
	<%}%>
	window.opener.focus();
	<%
	if(strFormName != null){%>
	window.opener.document.<%=strFormName%>.submit();
	<%}%>
	self.close()
	} else {
	location = "./lost_found_add.jsp?reference_no="+escape(strRefNo)+"&case_type="+
	(document.form1_.case_type.selectedIndex + 1);
	}
}
function CallPrintPage() {
	<%if(WI.fillTextValue("pring_pg").length() == 0) {%>
		return;
	<%}%>
	
	document.bgColor = "#FFFFFF";
	
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);

	document.getElementById('myADTable3').deleteRow(0);

	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function PrintPage() {
	document.form1_.pring_pg.value='1';
	document.form1_.submit();
}
</script>

<body bgcolor="#D2AE72" onLoad="CallPrintPage();">
<%
	String strErrMsg = null;
	String strTemp = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-Lost & Found","lost_found_viewall.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs","Lost & Found",request.getRemoteAddr(),
														"lost_found_viewall.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
Vector vRetResult = null;//It has all information.
String strCaseType = WI.fillTextValue("case_type");

LostFound LF = new LostFound();
strCaseType = WI.fillTextValue("case_type");
if(strCaseType.length() > 0) {//System.out.println(".."+WI.fillTextValue("page_action"));
	if(WI.fillTextValue("page_action").length() > 0) {
		if(LF.operateOnLostFoundClaimItem(Integer.parseInt(strCaseType),dbOP, request,0, null) == null)
			strErrMsg = LF.getErrMsg();
		else
			strErrMsg = "Item removed successfully.";
	}
	vRetResult = LF.operateOnLostFoundClaimItem(Integer.parseInt(strCaseType),dbOP, request,4, null);
	if(vRetResult == null)
		strErrMsg = LF.getErrMsg();
		

}

boolean bolPrintCalled = false;
if(WI.fillTextValue("pring_pg").length() > 0) 
	bolPrintCalled = true;
%>
<form action="./lost_found_viewall.jsp" method="post" name="form1_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>::::
          LOST &amp; FOUND - VIEW/EDIT/DELETE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td width="2%" height="30">&nbsp;</td>
      <td width="24%" height="30">Case type
        <select name="case_type" onChange="ReloadPage();">
          <%
strTemp = WI.fillTextValue("case_type");
if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Lost</option>
          <%}else{%>
          <option value="1">Lost</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Found</option>
          <%}else{%>
          <option value="2">Found</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>Claimed</option>
          <%}else{%>
          <option value="3">Claimed</option>
          <%}%>
        </select></td>
      <td width="40%" height="30">Item Category
        <select name="item_index" onChange="ReloadPage()">
		<option value="">ALL</option>
          <%=dbOP.loadCombo("ITEM_INDEX","ITEM_NAME"," FROM OSA_PRELOAD_LF_ITEM ",WI.fillTextValue("item_index"),false)%>
        </select> </td>
      <td width="34%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Date: 
	  <input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
				value="<%=WI.fillTextValue("date_fr")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			
	  <a href="javascript:show_calendar('form1_.date_fr');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
	  to
	  <input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
				value="<%=WI.fillTextValue("date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			
	  <a href="javascript:show_calendar('form1_.date_to');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
	  </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4"><div align="right"></div></td>
    </tr>
	</table>
<%
if(strCaseType.compareTo("3") != 0 && vRetResult != null && vRetResult.size() > 0) {
strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() > 0 && WI.fillTextValue("date_to").length() > 0) 
	strTemp += " - "+WI.fillTextValue("date_to");
if(strTemp.length() > 0)
	strTemp = " Report for Date: "+strTemp;

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td height="25" style="font-size:9px;" align="right">
	  <a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a> Print Page
	  </td>
    </tr>
  </table>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9" align="center" style="font-weight:bold; font-size:11px;">
	  	LIST OF CASE TYPE <%=WI.fillTextValue("case_type_name").toUpperCase()%>, ITEM CATEGORY <%=WI.fillTextValue("item_name").toUpperCase()%>
		<%=WI.getStrValue(strTemp, "<br>","","")%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="9" class="thinborder"><div align="left"><b>Total 
          Entries : <%=vRetResult.size()/10%> </b></div>
        </td>
    </tr>
    <tr>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">REFERENCE #</font></strong></td>
      <td width="12%" height="25" class="thinborder"><div align="center"><strong><font size="1">DATE</font></strong></div></td>
      <td width="21%" class="thinborder"><div align="center"><strong><font size="1">REPORTED BY</font></strong></div></td>
      <td width="26%" align="center" class="thinborder"><strong><font size="1">CONTACT INFO </font></strong></td>
      <td width="26%" class="thinborder"><div align="center"><strong><font size="1">LOCATION</font></strong></div></td>
      <td width="29%" class="thinborder"><div align="center"><strong><font size="1">ITEM NAME</font></strong></div></td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">IS CLAIMED</font></strong></td>
 <%if(!bolPrintCalled){%>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
 <%}%>
    </tr>
    <%
	boolean bolIsClaimed = false;
	for(int i = 0 ; i < vRetResult.size(); i += 11){
		if(vRetResult.elementAt( i + 9) != null)
			bolIsClaimed = true;
		else
			bolIsClaimed = false;
		%>
    <tr>
      <td class="thinborder"><a href='javascript:EditInfo("<%=(String)vRetResult.elementAt(i+2)%>");'><%=(String)vRetResult.elementAt(i + 2)%></a></td>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"> 
<%
strTemp = (String)vRetResult.elementAt(i+6)+WI.getStrValue((String)vRetResult.elementAt(i+5), " (",")", "");
%> <%=strTemp%> </td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td align="center" class="thinborder"> &nbsp; <%if(bolIsClaimed){%> <img src="../../../images/tick.gif"> <%}%> </td>
 <%if(!bolPrintCalled){%>
      <td align="center" class="thinborder"> <%if(!bolIsClaimed && iAccessLevel == 2){%>
	  	<a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)">
        <img src="../../../images/delete.gif" border="0"></a> <%}else{%>
        N/A
        <%}%> </td>
<%}%>
    </tr>
    <%}%>
  </table>
<%}else if(vRetResult != null && vRetResult.size() > 0){
strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() > 0 && WI.fillTextValue("date_to").length() > 0) 
	strTemp += " - "+WI.fillTextValue("date_to");
if(strTemp.length() > 0)
	strTemp = " Report for Date: "+strTemp;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td height="25" style="font-size:9px;" align="right">
	  <a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a> Print Page
	  </td>
    </tr>
  </table>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="9" align="center" style="font-weight:bold; font-size:11px;">
	  	LIST OF ENTRIES FOR CLAIMED ITEMS UNDER ITEM CATEGORY <%=WI.fillTextValue("item_name").toUpperCase()%>
		<%=WI.getStrValue(strTemp, "<br>","","")%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="5" class="thinborder"><b>Total Entries : <%=vRetResult.size()/10%></b></td>
    </tr>
    <tr align="center" style="font-weight:bold">
      <td width="12%" height="25" class="thinborder" style="font-size:9px;">DATE</td>
      <td width="28%" class="thinborder" style="font-size:9px;">CLAIMED BY</td>
      <td width="54%" class="thinborder" style="font-size:9px;">SUPPORTING DOCUMENTS PRESENTED UPON CLAIMING</td>
      <td width="8%" class="thinborder" style="font-size:9px;">ITEM NAME</td>
<%if(!bolPrintCalled){%>
      <td width="8%" class="thinborder" style="font-size:9px;">DELETE</td>
<%}%>
    </tr>
<%for(int i = 0 ; i< vRetResult.size() ; i += 11){%>
    <tr>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder">
        <%
strTemp = (String)vRetResult.elementAt(i + 7)+
	WI.getStrValue((String)vRetResult.elementAt(i + 6), " (",")", "");
%>
        <%=strTemp%> </td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 9)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
 <%if(!bolPrintCalled){%>
      <td class="thinborder">
        <%if(iAccessLevel == 2){%>
        <a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)">
        <img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        N/A
        <%}%>
      </td>
<%}%>
    </tr>
<%}%>
  </table>
<%}//end of displaying claim item.%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable4">
    <tr >
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="item_name" value="">
<input type="hidden" name="case_type_name">
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">

<input type="hidden" name="pring_pg">
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
