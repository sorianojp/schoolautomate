<%@ page language="java" import="utility.*,purchasing.PO,enrollment.FacultyManagement,java.util.Vector" %>
<%	
	WebInterface WI = new WebInterface(request);
%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function CloseWindow(){
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();		
}
function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();	
}
function ReloadPage(){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.pageReloaded.value = "1";			
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function PageAction(strAction,strInfoIndex,strDel){
	document.form_.donot_call_close_wnd.value = 1;
	if(strAction == 0){
		if(!confirm('Delete '+strDel+' from signatory list?'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;	
	this.SubmitOnce('form_');
}
function CancelClicked(){
	document.form_.donot_call_close_wnd.value = 1;
	location = "./purchasing_officers.jsp?req_index=<%=WI.fillTextValue("req_index")%>&req_item_index="+
	"<%=WI.fillTextValue("req_item_index")%>&encode_pop=1&sign_type=<%=WI.fillTextValue("sign_type")%>";
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchEmployee",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<%

//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-signatory"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
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
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"PURCHASING-signatory","purchasing_officers.jsp");
	
	FacultyManagement FM = new FacultyManagement();	
	PO Po = new PO();
	Vector vRetResult = new Vector();
	Vector vUserDetail = null;
	String strErrMsg = null;
	String strTemp = null;
	String strInfoIndex = WI.fillTextValue("info_index");
	
	String strSYFr   = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	String strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	String strCurSem = (String)request.getSession(false).getAttribute("cur_sem");
	
	String strEmployeeIndex = dbOP.mapOneToOther("user_table","id_number","'"+WI.fillTextValue("emp_id")+"'",
							"user_index"," and (auth_type_index is null or (auth_type_index <>4 and auth_type_index<>6))");
	if (WI.fillTextValue("emp_id").length() > 0){
		vUserDetail = FM.viewFacultyDetail(dbOP, strEmployeeIndex, strSYFr, strSYTo, strCurSem);
	
	}
	String strPageAction = WI.fillTextValue("page_action");

	if(strPageAction.length() > 0) {
		if(Po.operateOnPOSignatories(dbOP, request, Integer.parseInt(strPageAction)) == null){	
			strErrMsg = Po.getErrMsg();
			}
		else {	
			if(strPageAction.equals("0"))
				strErrMsg = "Employee ID successfully deleted.";			
		}
	}
	vRetResult = Po.operateOnPOSignatories(dbOP,request,4);
	int iLoop = 0;
%>
<form name="form_" method="post" action="./purchasing_officers.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          PURCHASING OFFICERS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="85%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        &nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong> </td>
      <td width="15%"><div align="right"><a href="javascript:CloseWindow();"> 
          <img src="../../../images/close_window.gif" border="0"> </a></div></td>
    </tr>
  </table>
  <table width="100%" height="56" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="19" height="30">&nbsp;</td>
      <td width="162">Employee ID </td>
	  <%
	  	strTemp = WI.fillTextValue("emp_id");
	  %>
      <td width="159"><input type="text" name="emp_id" value="<%=WI.getStrValue(strTemp,"")%>">&nbsp;</td>
      <td width="357" colspan="3"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5"><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a><font size="1">Click 
        to reload page.</font></td>
    </tr>
	</table>	
	
  <table width="100%" height="106" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(vUserDetail != null && vUserDetail.size() > 0 ){%>
    <tr> 
      <td width="3%" height="18">&nbsp;</td>
      <td width="18%"> Name</td>
      <%if(vUserDetail != null && vUserDetail.size() > 0 ){ 
	     strTemp =(String)vUserDetail.elementAt(1);
		}else{
		  strTemp = "";
		}
	  %>
      <td colspan="2"><strong><%=WI.getStrValue(strTemp," ")%></strong></td>
      <td width="15%"><div align="left">Emp. Status</div></td>
      <%if(vUserDetail != null && vUserDetail.size() > 0 ){ 
	     strTemp =(String)vUserDetail.elementAt(2);
		}else{
		  strTemp = "";
		}
	  %>
      <td width="36%" colspan="2">&nbsp;<strong><%=WI.getStrValue(strTemp," ")%></strong></td>
    </tr>
    <tr > 
      <td height="18">&nbsp;</td>
      <td><%if(bolIsSchool){%>
        College 
        <%}else{%>
        Division 
        <%}%>
        /Office</td>
      <%if((String)vUserDetail.elementAt(4) == null || (String)vUserDetail.elementAt(5) == null){ 
	     strTemp = " ";
		}else{
		  strTemp = "-";
		}
	  %>
      <td colspan="2"><strong><%=WI.getStrValue(vUserDetail.elementAt(4),"")%><%=strTemp%><%=WI.getStrValue(vUserDetail.elementAt(5),"")%></strong></td>
      <td><div align="left">Emp. Type</div></td>
      <td colspan="2">&nbsp;<strong	><%=WI.getStrValue((String)vUserDetail.elementAt(7),"")%></strong></td>
    </tr>
    <tr> 
      <td height="18" colspan="6">&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="34" colspan="6"><div align="center"><font size="1"> <a href="javascript:PageAction(1,'','');"> 
          <img src="../../../images/add.gif" border="0"></a>click to ADD signatory 
          details <a href="javascript:CancelClicked();"> <img src="../../../images/cancel.gif" border="0"></a>click 
          to CANCEL entries </font></div></td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="4" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>PURCHASING 
          SIGNATORIES </strong></font></div></td>
    </tr>
    <tr> 
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>COUNT</strong></font></div></td>
      <td width="39%" height="25" class="thinborder"><div align="center"><font size="1"><strong>PURCHASING 
          OFFICER </strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>ID</strong></font></div></td>
      <td width="19%" class="thinborder"><div align="center"><font size="1"><strong>DELETE</strong></font></div></td>
    </tr>	
	<%for (iLoop = 0;iLoop < vRetResult.size();iLoop+=5){%>
    <tr> 
      <td class="thinborder"><div align="center"><%=(iLoop+5)/5%></div></td>
      <td height="35" class="thinborder"><div align="left"><font size="1"><strong><%=WI.formatName((String)vRetResult.elementAt(iLoop+1), (String)vRetResult.elementAt(iLoop+2),
							(String)vRetResult.elementAt(iLoop+3), 7).toUpperCase()%></strong></font></div></td>
      <td class="thinborder"><div align="left"><font size="1"><strong><%=(String)vRetResult.elementAt(iLoop+4)%></strong></font></div></td>
      <td class="thinborder"><div align="center"> <a href="javascript:PageAction(0,'<%=(String)vRetResult.elementAt(iLoop)%>','<%=(String)vRetResult.elementAt(iLoop+4)%>')"> 
          <img src="../../../images/delete.gif" border="0"></a></div></td>
    </tr>
	<%}%>
  </table>
	<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table> 
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="page_action" value="<%=WI.fillTextValue("page_action")%>">
  <input type="hidden" name="pageReloaded" value="">  
  <input type="hidden" name="opner_form_name" value="<%=WI.fillTextValue("opner_form_name")%>">
  <input type="hidden" name="sign_type" value="<%=WI.fillTextValue("sign_type")%>">
  
  <!--<input type="hidden" name="opner_form_name" value="<%//=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>"> -->
  <!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>