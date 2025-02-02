<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/common.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function FocusID() {
	document.form_.stud_id.focus();
}
function AddRecord()
{
	document.form_.page_action.value = "1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.submit();
	
}

function DeleteRecord(){
	document.form_.page_action.value ="0";
	document.form_.submit();
}
function ReloadPage()
{
	document.form_.page_action.value="3";
	document.form_.submit();
}

function ClearAll(){

	document.form_.appl_no.value="";
	document.form_.appl_amt.value="";
	document.form_.date_application.value="";
	
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function LoadEducPlans(){
	var pgLoc = "../payment_maintenance/fee_assess_pay_aff_inst_payee.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.FAEducPlans,enrollment.EnrlAddDropSubject,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;



	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Fee adjustments","fee_adjustment.jsp");
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
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"fee_adjustment.jsp");
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

//end of authenticaion code.
String[] astrConvertYrLevel={"","First", "Second","Third", "Fourth", "Fifth", "Sixth"};
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
String[] astrConvertProper={"","Preparatory","Proper"};
String[] astrConvertStatus={"DISAPPROVED","APPROVED","PENDING"};
Vector vStudInfo = null;
Vector vEducPlanInfo = null;
Vector vRetResult = null;
EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();
FAEducPlans faEP = new FAEducPlans();



	if (WI.fillTextValue("stud_id").length() > 0 && WI.fillTextValue("sy_from").length() > 0){
		vStudInfo = enrlAddDropSub.getEnrolledStudInfo(dbOP, (String)request.getSession(false).getAttribute("userId"),
													request.getParameter("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
													WI.fillTextValue("semester"));
		if(vStudInfo == null) strErrMsg = enrlAddDropSub.getErrMsg();}

	if (WI.fillTextValue("educ_plan").length() >0){
		vEducPlanInfo = faEP.getEducPlanInfo(dbOP,WI.fillTextValue("educ_plan"));
	
		if (vEducPlanInfo == null) {
			strErrMsg = faEP.getErrMsg();
		}else{
			vRetResult = faEP.operateOnEducPlans(dbOP,request,3);
		}
	}
	
	int iPageAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));
	

	
	if (WI.fillTextValue("educ_plan").length() != 0){
		if (iPageAction == 0 || iPageAction == 1 || iPageAction == 2 || iPageAction == 3 ){
		
			vRetResult = faEP.operateOnEducPlans(dbOP,request,iPageAction);
			
			if (vRetResult == null ){
				strErrMsg = faEP.getErrMsg();
			}else{
				switch(iPageAction){
					case 0: strErrMsg = " Student educational plan removed successfully"; break;
					case 1: strErrMsg = " Student educational plan added successfully"; break;
					case 2: strErrMsg = " Student educational plan edited successfully"; break;
				}// end swith
			}// end vRetResult == null
		} // end iPageAction 
	} // end educ_plan lenght > 0
%>
<form name="form_" action="./educ_plans_ap_mgmt.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="24" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          EDUCATIONAL PLANS - APPLICATION MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25">Enter Student ID</td>
      <td width="11%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="7%" height="25"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="61%"><input name="image" type="image" src="../../../images/form_proceed.gif" width="81" height="21"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%" height="25">School Year/Term</td>
      <td height="25" colspan="3">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
        -
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" valign="bottom">&nbsp;</td>
    </tr>
  </table>
<% if(vStudInfo != null && vStudInfo.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="2" height="25"><hr size="1"></td>
    </tr>
    <tr> 
      <td  width="2%" height="25">&nbsp;</td>
      <td width="98%" height="25">Student name :<strong> <%=(String)vStudInfo.elementAt(1)%> 
        <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
        <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(4)%>">
        </strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Course / Major:<strong> <%=(String)vStudInfo.elementAt(2)%> <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;Year :<strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(4),"0"))]%> <%=astrConvertProper[Integer.parseInt((String)vStudInfo.elementAt(14))]%></strong> </td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2" height="15" colspan="2"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="22%">Educational Plans Code</td>
      <td width="76%"><strong> 
        <select name="educ_plan" onChange="ReloadPage();">
          <option value="">Select</option>
          <%=dbOP.loadCombo("AI_INDEX","AFF_INST_CODE" ," from FA_AFFILIATED_INST where IS_DEL=0 ",
		   request.getParameter("educ_plan"), false)%> 
        </select>
        &nbsp;<a href="javascript:LoadEducPlans()"><img src="../../../images/update.gif" width="60" height="26" border="0"></a></strong><font size="1"> 
        click to update list of educational plans</font></td>
    </tr>
<%
	if (vEducPlanInfo !=null && vEducPlanInfo.size() > 0){
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Educational Plan Name</td>
      <td><strong><%=WI.getStrValue((String)vEducPlanInfo.elementAt(2),"&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Contact Person</td>
      <td><strong><%=WI.getStrValue((String)vEducPlanInfo.elementAt(3),"&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Position</td>
      <td><strong><%=WI.getStrValue((String)vEducPlanInfo.elementAt(4),"&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Contact Nos.</td>
      <td><strong><%=WI.getStrValue((String)vEducPlanInfo.elementAt(5),"&nbsp;")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Address</td>
      <td><strong><%=WI.getStrValue((String)vEducPlanInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
<% } // if vEducPlanInfo !=null%>
    <tr> 
      <td height="15" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%
	if (vEducPlanInfo !=null && vEducPlanInfo.size() > 0){
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 <%
	if (iPageAction == 3 && vRetResult!=null  && vRetResult.size() > 0){
		strTemp = (String)vRetResult.elementAt(6);
	}else{
		strTemp = WI.fillTextValue("appl_no");
	}	
%>
    <tr> 
      <td width="2%" height="24">&nbsp;</td>
      <td width="20%" height="24">Application No.</td>
      <td width="78%" height="24"><input name="appl_no" type="text" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=strTemp%>" size="16" maxlength="16"></td>
    </tr>
<%
	if (iPageAction == 3 && vRetResult!=null  && vRetResult.size() > 0){
		strTemp = (String)vRetResult.elementAt(7);
	}else{
		strTemp = WI.fillTextValue("appl_amt");
	}	
%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"> Applied Amount</td>
      <td height="25"><font size="1"> 
        <input name="appl_amt"  value="<%=strTemp%>"  type="text" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" class="textbox" size="16" maxlength="16">
        </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"> Date Application</td>
<%
	if (iPageAction == 3 && vRetResult!=null  && vRetResult.size() > 0){
		strTemp = (String)vRetResult.elementAt(10);
	}else{
		strTemp = WI.fillTextValue("date_application");
	}	
%>
      <td height="25"><font size="1"> 
        <input name="date_application"  type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_application');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        </font></td>
    </tr>
<%
	if (iPageAction == 3 && vRetResult!=null && vRetResult.size() > 0){
		strTemp = astrConvertStatus[Integer.parseInt((String)vRetResult.elementAt(9))];
	}else{
		strTemp = "PENDING";
	}	
%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Status </td>
      <td height="25"><strong><%=strTemp%></strong>&nbsp;</td>
    </tr>
<%
	if (iPageAction == 3 && vRetResult!=null && vRetResult.size() > 0){
		strTemp =(String)vRetResult.elementAt(0);
	}else{
		strTemp = "";
	}
%>

    <tr> 
      <td height="25">&nbsp;<input type="hidden" name="info_index" value="<%=strTemp%>"></td>
      <td height="25">&nbsp;</td>
      <td height="25"><font size="1">&nbsp;</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%" height="25"><div align="left"></div></td>
      <td width="80%" height="25"> 
 <%
 	if(iAccessLevel > 1){
 	if (iPageAction == 3 && vRetResult!=null && vRetResult.size() > 0 && iAccessLevel==2){ %>
        <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a> 
        <font size="1">click to save changes</font> <a href="javascript:DeleteRecord()"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <font size="1"> click to delete educational plan</font> 
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/save.gif" name="hide_save" width="48" height="28" border="0"></a> 
        <font size="1">click to save entries</font> <a href="javascript:ClearAll()"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
        to cancel and clear entries</font> 
        <% } 
  }//if iAccessLevel > 1%>
		</td>
    </tr>

	</table>
<%} // if vEducPlanInfo not found
  } // if vStudInfo  not found %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
