<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
<!--
function AddRecord(){
	document.form_.page_action.value = "1";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value="0";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex){
	document.form_.prepareToEdit.value="1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.reloadPage.value ="1";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.page_action.value="2";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location = "./lock_fee_allow_extn.jsp";
}

function ReloadPage()
{
	document.form_.page_action.value = "";
	this.SubmitOnce("form_");
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg() {

	window.print();
}
-->
</script>
<body onLoad="window.print()">
<%@ page language="java" import="utility.*,enrollment.SetParameter,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameters","lock_fee_allow_extn.jsp");
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
														"System Administration","Set Parameters",request.getRemoteAddr(),
														"lock_fee_allow_extn.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"System Administration","Set Parameters",request.getRemoteAddr(),
															"lock_fee_allow_extn.jsp");}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vEditInfo = null;
Vector vRetResult = null;
SetParameter paramGS = new SetParameter();

vRetResult = paramGS.operateOnLockFeeAE(dbOP,request,4);
if(vRetResult == null)
{
	if(strErrMsg == null)
		strErrMsg = paramGS.getErrMsg();
}
String[] astrSemester = {"Summer","1st Sem","2nd Sem"," 3rd Sem"};
String[] astrFeeType =  {"ALL","Tuition","Misc / Other Charges"};

%>
<form name="form_" action="./lock_fee_allow_extn.jsp" method="post">
  <% if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> 
          </strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>
          <font size="1"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> <br>
          <br>
        </div></td>
    </tr>
    <tr>
      <td height="25"><div align="center"><strong>DATES ALLOWED TO EDIT FEE MAINTENANCE</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="14%" height="30" class="thinborder"><div align="center"><strong><font size="1">COURSE </font></strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">FEE TYPE</font></strong></div></td>
      <td width="16%" class="thinborder"><div align="center"><strong><font size="1">FEE NAME </font></strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong><font size="1">REQUESTED BY 
          </font></strong></div></td>
      <td width="12%" class="thinborder"><font size="1"><strong>ALLOW DATE EDIT</strong></font></td>
      <td width="37%" class="thinborder"><div align="center"><strong><font size="1">REASON</font></strong></div></td>
    </tr>
    <%for(int i =0;i< vRetResult.size(); i +=14){%>
    <tr> 
      <td height="25" align="center" class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3),"ALL") + WI.getStrValue((String)vRetResult.elementAt(i+5), " :: " ,"","")%></font></td>
      <td align="center" class="thinborder"><font size="1">&nbsp;<%=astrFeeType[Integer.parseInt((String)vRetResult.elementAt(i+7))]%></font></td>
      <td align="center" class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8),"ALL")%></font></td>
      <td align="center" class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+10))%></font></td>
      <td align="center" class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9),"ALL")%></font></td>
      <td align="center" class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+11))%></font></td>
    </tr>
    <%} // end for loop	%>
  </table>
<%}// end if vRetResult != null %>
  <input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="reloadPage" value="<%=WI.fillTextValue("reloadPage")%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
