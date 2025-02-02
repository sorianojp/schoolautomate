<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.ViolationConflict"%>
<%
		WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PageAction(strAction){
	document.form_.page_action.value=strAction;
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname +
	"&colname=" + colname+"&label="+labelname+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function GoBack() {
	location = document.form_.parent_url.value;
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-VIOLATIONS & CONFLICTS","vio_conflict_update.jsp");
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
														"Student Affairs","VIOLATIONS & CONFLICTS",request.getRemoteAddr(),
														"vio_conflict_update.jsp");
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
Vector vRetResult = new Vector();//It has all information.

String strInfoIndex = WI.fillTextValue("info_index");
ViolationConflict VC = new ViolationConflict();
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem","5th Sem","ALL"};


	vRetResult = VC.operateOnViolation(dbOP, request,3);
	if(vRetResult == null)
		strErrMsg = VC.getErrMsg();

%>
<body bgcolor="#FFFFFF">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2"><div align="center">
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <!-- Martin P. Posadas Avenue, San Carlos City -->
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%>
          <!-- Pangasinan 2420 Philippines -->
          <br><br>
          <strong>STUDENT DEVELOPMENT OFFICE</strong>
          <br><br>
          <strong>CASE DETAIL</strong><br>
		  </div></td>
  </tr>
</table>
<%if (vRetResult != null && vRetResult.size()>0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="30">&nbsp;</td>
      <td width="21%">&nbsp;</td>
      <td width="16%">&nbsp;</td>
      <td width="61%">&nbsp;</td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="top"><strong>SY-TERM</strong></td>
      <td colspan="2" valign="top"> <%=strTemp = (String)vRetResult.elementAt(1)%>
        -
        <%=(String)vRetResult.elementAt(2)%>
        -
        <%=astrConvertSem[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(3),"6"))]%></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="top"><strong>Date Of Violation</strong></td>
      <td colspan="2" valign="top"><%=(String)vRetResult.elementAt(4)%></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="top"><strong>Date reported</strong></td>
      <td colspan="2" valign="top"><%=(String)vRetResult.elementAt(5)%></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="top"><strong>Case #</strong></td>
      <td colspan="2" valign="top"> <%=(String)vRetResult.elementAt(6)%> </td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="top"><strong>Incident Type</strong></td>
      <td colspan="2" valign="top"> <%=(String)vRetResult.elementAt(8)%></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="top"><strong>Incident</strong></td>
      <td colspan="2" valign="top"><%=(String)vRetResult.elementAt(15)%></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="top"><strong>Charged Party</strong></td>
      <td colspan="2" valign="top"> <%=(String)vRetResult.elementAt(13)%></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="top"><strong>Complainant</strong></td>
      <td colspan="2" valign="top"><%=(String)vRetResult.elementAt(16)%></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="top"><strong>Report of Description</strong></td>
      <td colspan="2" valign="top"><%=(String)vRetResult.elementAt(9)%></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="top"><strong>Action Taken</strong></td>
      <td colspan="2" valign="top"><%=(String)vRetResult.elementAt(10)%></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="top"><strong>Recommendation</strong></td>
      <td colspan="2" valign="top"> <%=(String)vRetResult.elementAt(11)%></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
    <script language="JavaScript">
		window.print();
	</script> 
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
