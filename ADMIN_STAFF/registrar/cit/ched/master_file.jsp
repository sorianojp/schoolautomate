<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transferee Info Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PareparedToEdit(strInfoIndex) {
	document.form_.preparedToEdit.value = '1';
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = '';
	document.form_.submit();
}
function PageAction(strInfoIndex, strAction) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this record'))
			return;
	}
	if(strAction == '5') {
		if(!confirm('Are you sure you want to Invalidate this record'))
			return;
	}
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
function PrintMasterFile(strInfoIndex) {
	var strPgLoc = "./master_file_print.jsp?sy_from="+document.form_.sy_from.value+"&semester="+
				document.form_.semester[document.form_.semester.selectedIndex].value+
				"&scholar_type="+document.form_.scholar_type[document.form_.scholar_type.selectedIndex].value
	
	var win=window.open(strPgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintOneStudent(strInfoIndex, strStudI) {
	var strPgLoc = "./print_one.jsp?info_i="+strInfoIndex;
	
	var win=window.open(strPgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CITChedBilling,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CHED Scholar-manage Scholarship Type","master_file.jsp");
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
														"Registrar Management","CHED SCHOLAR",request.getRemoteAddr(),
														"master_file.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

CITChedBilling CCB = new CITChedBilling();
Vector vRetResult = null; 
String strPrevSYTerm = null;
String[] astrConvertSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM"};

strTemp = WI.fillTextValue("page_action");
if(strTemp.equals("0")) {
	strTemp = "update CIT_CHED_SCHOLAR set is_valid = 0 where SCHOLAR_INDEX = "+WI.fillTextValue("info_index");
	dbOP.executeUpdateWithTrans(strTemp, null, null, false);
}

if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = CCB.generateMasterFile(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = CCB.getErrMsg();

	//make the prev sy/term information.
	int iSYFrom   = Integer.parseInt(WI.fillTextValue("sy_from"));
	int iSYTo     = iSYFrom + 1;
	int iSemester = Integer.parseInt(WI.fillTextValue("semester"));
	
	if(iSemester == 1) {
		--iSYFrom; --iSYTo;
		iSemester = 2;
	}
	else
		iSemester = 1;
	
	strPrevSYTerm= astrConvertSem[iSemester]+", AY "+Integer.toString(iSYFrom)+" - "+Integer.toString(iSYTo);
}


%>
<form action="./master_file.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          SCHOLARSHIP MASTERFILE :::: </strong></font></div></td>
    </tr>
  </table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
		<td width="2%" height="25" colspan="4">&nbsp;</td>
      <td width="98%"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25">&nbsp;</td>
      <td>SY-Term</td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = WI.getStrValue((String)request.getSession(false).getAttribute("cur_sch_yr_from"));
%>
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  
	  - 
	  
	  <select name="semester">
          <option value="0">Summer</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = WI.getStrValue((String)request.getSession(false).getAttribute("cur_sem"));
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1" <%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3" <%=strErrMsg%>>3rd Sem</option>
        </select>	
	  </td>
    </tr>
	<tr>
	  <td width="4%" height="25">&nbsp;</td>
	  <td width="16%">Scholarship Type </td>
	  <td width="80%">
		<select name="scholar_type">
          <%=dbOP.loadCombo("SCHOLAR_TYPE_INDEX","SCHOLAR_CODE,SCHOLAR_NAME"," from CIT_CHED_SCHOLAR_TYPE where is_valid = 1 and IN_ACTIVE = 0 order by scholar_code", WI.fillTextValue("scholar_type"), false)%>
		</select>
	  </td>
    </tr>
	<tr>
	  <td height="25">&nbsp;</td>
	  <td>&nbsp;</td>
	  <td>
	  <input type="submit" name="_update_info" value="Show List">
	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	  <td height="25" align="right" style="font-size:9px">
	  Rows Per page: 
	  <select name="rows_per_page">
<%
strTemp = request.getParameter("rows_per_page");
if(strTemp == null)
	strTemp = "40";
int iDef = Integer.parseInt(strTemp);

for(int i = 30; i < 60; ++i) {
	if( i == iDef)
		strTemp = " selected";
	else
		strTemp = "";
%>
      <option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
	  
	  <a href="javascript:PrintMasterFile();"><img src="../../../../images/print.gif" border="0"></a> Print Master File &nbsp;&nbsp;</td>
    </tr>
	</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
      <td height="25" colspan="13" align="center" style="font-weight:bold" class="thinborder" bgcolor="#CCCCCC">STUDENT MASTER FILE</td>
    </tr>
    <tr align="center" style="font-weight:bold">
      <td width="3%" height="25" style="font-size:9px" class="thinborder">COUNT</td>
      <td width="10%" style="font-size:9px" class="thinborder">AWARD NO.</td>
      <td width="10%" style="font-size:9px" class="thinborder">LAST NAME</td>
      <td width="10%" style="font-size:9px" class="thinborder">FIRST NAME</td>
      <td width="3%" style="font-size:9px" class="thinborder">MI</td>
      <td width="3%" style="font-size:9px" class="thinborder">SEX</td>
      <td width="12%" style="font-size:9px" class="thinborder">COURSE</td>
      <td width="4%" style="font-size:9px" class="thinborder">YEAR LEVEL</td>
      <td width="10%" style="font-size:9px" class="thinborder"> GRADES-GWA GRANTEES <br>
					   PREVIOUS SEMESTER<br>
					   <%=strPrevSYTerm%>	  </td>
      <td width="10%" style="font-size:9px" class="thinborder"> CURRENT SEMESTER <br>
	  				   UNITS ENROLLED<br>
					   <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, AY <%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%></td>
      <td width="10%" style="font-size:9px" class="thinborder">REMARKS*</td>
      <td width="5%" style="font-size:9px" class="thinborder">PRINT</td>
      <td width="5%" style="font-size:9px" class="thinborder">REMOVE</td>
    </tr>
<%
int iCount =0; 
for(int i = 0;i < vRetResult.size(); i += 15) {%>
    <tr>
      <td height="25" style="font-size:9px" class="thinborder"><%=++iCount%></td>
      <td style="font-size:9px" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td style="font-size:9px" class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
      <td style="font-size:9px" class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
<%
strTemp = (String)vRetResult.elementAt(i + 5);
if(strTemp != null) {
	if(strTemp.length() > 0)
		strTemp = String.valueOf(strTemp.charAt(0));
}%>
      <td style="font-size:9px" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
      <td style="font-size:9px" class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
<%
//course.. 
strTemp = (String)vRetResult.elementAt(i + 8);
if(vRetResult.elementAt(i + 10) != null) {
	strTemp = strTemp + " - "+(String)vRetResult.elementAt(i + 10);
}%>
      <td style="font-size:9px" class="thinborder"><%=strTemp%></td>
      <td style="font-size:9px" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 12),"&nbsp;")%></td>
      <td style="font-size:9px" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3),"&nbsp;")%></td>
      <td style="font-size:9px" class="thinborder"><%=vRetResult.elementAt(i + 13)%></td>
      <td style="font-size:9px" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 2),"&nbsp;")%></td>
      <td align="center" class="thinborder"><a href="javascript:PrintOneStudent('<%=vRetResult.elementAt(i)%>', '<%=vRetResult.elementAt(i + 14)%>');"><img src="../../../../images/print.gif" border="0"></a></td>
      <td align="center" class="thinborder"><a href="javascript:PageAction('<%=vRetResult.elementAt(i)%>', '0');"><img src="../../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
<%}%>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index">
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
