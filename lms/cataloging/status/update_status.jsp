<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	color: #000080;

	
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	
}

.bodystyle {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction() {
	document.form_.page_action.value = "1";
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
}
function UpdateStatus() {
	document.form_.page_action.value = "1";
	document.form_.submit();
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
	Vector vRetResult      = null;
	String[] astrBookStat  = null;
	String strBookIndex    = WI.fillTextValue("book_index");//get from accession number. 

	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(lUtil.operateOnCollectionStatus(dbOP, request, strBookIndex, Integer.parseInt(strTemp)) == null )
			strErrMsg = lUtil.getErrMsg();
		else	
			strErrMsg = "Book Status updated successfully.";
	}
	
	astrBookStat = lUtil.getOrUpdateBookStatus(dbOP, strBookIndex,null);
	if(astrBookStat == null) 
		strErrMsg = lUtil.getErrMsg();

	//view tracking.. 
	vRetResult = lUtil.operateOnCollectionStatus(dbOP, request, strBookIndex, 4);


%>
<body bgcolor="#D0E19D">
<form action="./update_status.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#77A251"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          COLLECTION STATUS UPDATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"> &nbsp;&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font> </td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="18%" height="25">Accession No. </td>
      <td width="23%"><strong><%=WI.fillTextValue("accession_number")%></strong></td>
      <td width="15%">Current Status</td>
      <td width="44%"><strong><%=astrBookStat[1]%></strong></td>
    </tr>
    <tr>
      <td height="20" colspan="4" align="center" bgcolor="#AABBDD"><strong>NEW STATUS </strong></td>
    </tr>
    <tr> 
      <td height="25">New Status</td>
      <td>
	 <select name="book_status" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 14;">
     <%=dbOP.loadCombo("BS_REF_INDEX","STATUS"," from LMS_BOOK_STAT_REF WHERE BS_REF_INDEX <> 2 order by BS_REF_INDEX asc",
	  astrBookStat[0], false)%>
	  </select>	</td>
      <td>Date of Update </td>
      <td>
<%
strTemp = WI.fillTextValue("stat_updated_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>	  <input name="stat_updated_date" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=strTemp%>">
        <a href="javascript:show_calendar('form_.stat_updated_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">SY-Term</td>
      <td><%
	  strTemp = WI.fillTextValue("sy_from");
	  if(strTemp.length() ==0) 
	  	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	  %>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeypress="AllowOnlyInteger('form_','sy_from');"
	  onKeyUp="DisplaySYTo();">
        <%
	  strTemp = WI.fillTextValue("sy_to");
	  if(strTemp.length() ==0) 
	  	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	  %>
-
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"></td>
      <td><select name="semester">
        <option value="0">Summer</option>
        <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.equals("1")){%>
        <option value="1" selected>1st Sem</option>
        <%}else{%>
        <option value="1">1st Sem</option>
        <%}if(strTemp.equals("2")){%>
        <option value="2" selected>2nd Sem</option>
        <%}else{%>
        <option value="2">2nd Sem</option>
        <%}if(strTemp.equals("3")){%>
        <option value="3" selected>3rd Sem</option>
        <%}else{%>
        <option value="3">3rd Sem</option>
        <%}%>
      </select></td>
      <td>Status Updated by: <strong><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><a href="javascript:UpdateStatus();"><img src="../../images/save_circulation.gif" border="0"></a>Click to update book status.</td>
    </tr>
    <tr>
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr>
      <td height="20" colspan="4" align="center" bgcolor="#AABBDD" class="thinborderBOTTOM"><strong>::: UPDATE STATUS TRACKING :: </strong></td>
    </tr>
    <tr> 
      <td width="18%" height="25" align="center"><strong>STATUS</strong></td>
      <td width="33%" align="center"><strong>DATE UPDATED </strong></td>
      <td width="40%" align="center"><strong>UPDATED BY </strong></td>
      <td width="9%" align="center"><strong><!--REMOVE--></strong></td>
    </tr>
<%
String[] astrConvertToSem = {"SU","FS","SS","TS"};
for(int i = 0; i < vRetResult.size(); i += 9){%>
    <tr>
      <td height="25" align="center"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i + 2)%><br>
	  <%=(String)vRetResult.elementAt(i + 5)%> - <%=(String)vRetResult.elementAt(i + 6)%>
	  (<%=astrConvertToSem[Integer.parseInt((String)vRetResult.elementAt(i + 7))]%>)</td>
      <td align="center"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td align="center">&nbsp;</td>
    </tr>
<%}%>
  </table>
<%}//show only if vRetResult is not null %>
<input type="hidden" name="page_action">
<input type="hidden" name="book_index" value="<%=WI.fillTextValue("book_index")%>">
<input type="hidden" name="accession_number" value="<%=WI.fillTextValue("accession_number")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>