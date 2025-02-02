<%@ page language="java" import="utility.*,java.util.Vector,eDTR.eDTRSettings" %>
<%
	///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Holiday Maintenance</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<script>
<!--
function PrintPg() {
	var pgLoc = "./set_eDTRSettings_print.jsp?yyyy_to_view="+
		document.dtr_op.yyyy_to_view.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function AddRecord(){
	document.dtr_op.print_pg.value = "";

	document.dtr_op.page_action.value ="1";
	document.dtr_op.submit();
}
function DeleteRecord(strTargetIndex){
	
	if(!confirm('Delete selected leave usage?'))
		return;
	
	document.dtr_op.print_pg.value = "";
	document.dtr_op.info_index.value = strTargetIndex;
	document.dtr_op.page_action.value = "0";
	document.dtr_op.submit();
}
function EditRecord(){
	document.dtr_op.print_pg.value = "";

	document.dtr_op.page_action.value = "2";
	document.dtr_op.submit();
}

function PrepareToEdit(strIndex){
	document.dtr_op.print_pg.value = "";

	document.dtr_op.prepareToEdit.value = "1";
	document.dtr_op.info_index.value = strIndex;
	document.dtr_op.submit();
}

function CancelRecord(){
	location = "./coc_mgmt.jsp";
}
 
function ReloadPage() {
	document.dtr_op.print_pg.value = "";
	document.dtr_op.submit();
}
-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = 
				WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = "";
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-DTR OPERATIONS-Holiday Maintenance","coc_mgmt.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"coc_mgmt.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = new Vector();
Vector vEditInfo= new Vector();
eDTRSettings eDtrSet = new eDTRSettings();
String[] astrPurpose = {"Late/undertime auto adjustment", "Compensatory Overtime Credit"};
String strPageAction = WI.fillTextValue("page_action");
strPrepareToEdit = WI.fillTextValue("prepareToEdit");

 if(strPageAction.length() > 0){
 		vRetResult = eDtrSet.operateOnLeaveBenefitUsage(dbOP,request, Integer.parseInt(strPageAction));
		if(vRetResult == null)
			strErrMsg = eDtrSet.getErrMsg();
		else
			strErrMsg = "Operation Successful";
 }

 if (strPrepareToEdit.equals("1")){
 		vEditInfo = eDtrSet.operateOnLeaveBenefitUsage(dbOP,request, 3);
 		if (vEditInfo == null)
			strErrMsg = eDtrSet.getErrMsg();	
 }
 
 vRetResult = eDtrSet.operateOnLeaveBenefitUsage(dbOP,request, 4);
%>
<form action="./coc_mgmt.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="5" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      LEAVE USAGE/PURPOSE MANAGEMENT PAGE ::::</strong></font></td>
    </tr>
	    <tr>
      <td height="25"><font size=3><strong><%=strErrMsg%>&nbsp;</strong></font></td>
    </tr>
</table>

  <table width="100%" border="0" align="center" bgcolor="#FFFFFF">
    <tr>
      <td width="5%">&nbsp;</td>
      <td width="26%">Leave</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(1);
				else
					strTemp = WI.fillTextValue("benefit_index");
			%>
      <td width="69%"><select name="benefit_index">
        <%=dbOP.loadCombo("benefit_index","sub_type"," from  hr_benefit_incentive " +
		 " join hr_preload_benefit_type on (hr_preload_benefit_type.benefit_type_index = hr_benefit_incentive.benefit_type_index)" +
		 " where is_benefit = 0 and benefit_name = 'leave' and is_valid = 1",strTemp,false)%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Usage of the Leave</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(2);
				else
					strTemp = WI.fillTextValue("purpose");
			%>
      <td><strong>
        <select name="purpose">
					<%for(int i = 0;i < astrPurpose.length;i++){
						if(strTemp.equals(Integer.toString(i))){
					%>
					<option value="<%=i%>" selected><%=astrPurpose[i]%></option>
					<%}else{%>
          <option value="<%=i%>"><%=astrPurpose[i]%></option>
					<%}
					}%>
        </select>
      </strong></td>
    </tr>
        
    <tr> 
      <td height="15" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="3" align="center"> 
				<%if(iAccessLevel > 1){%>
        <%
if((strPrepareToEdit!=null) && (strPrepareToEdit.compareTo("1") == 0))
{%>
        <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a><font size="1">click 
          to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a> 
        <font size="1">click to cancel or go previous</font> 
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a><font size="1">click 
          to add</font> 
        <%}%>
				<%}%>      </td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>
<% if (vRetResult !=null && vRetResult.size() > 0){ %>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <% for (int i = 0; i < vRetResult.size(); i+=5) { %>
    <%} // end for loop%>
    <tr> 
      <td width="100%">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="3" align="center" class="thinborder"><strong>LIST 
      OF LEAVE PURPOSE</strong></td>
    </tr>
    <tr> 
      <td width="41%" height="25" class="thinborder"><strong> &nbsp;NAME </strong></td>
      <td width="33%" class="thinborder"><strong>&nbsp;TYPE OF HOLIDAY</strong></td>
      <td width="26%" class="thinborder"><strong>&nbsp;OPTIONS</strong></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size(); i+=10) { %>
    <tr> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+2);				
				strTemp = astrPurpose[Integer.parseInt(WI.getStrValue(strTemp, "0"))];
			%>			
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder"><font size="1"> 
        <%if(iAccessLevel > 1){
	strTemp = (String)vRetResult.elementAt(i);
%>
        <a href='javascript:PrepareToEdit("<%=strTemp%>")'><img src="../../../images/edit.gif" alt="Edit Record" border="0"></a> 
        <%if(iAccessLevel ==2){%>
        <a href='javascript:DeleteRecord("<%=strTemp%>")'><img src="../../../images/delete.gif" alt="Delete Record" border="0"></a> 
        <%}}%>
        &nbsp; </font></td>
    </tr>
    <%} // end for loop%>
  </table>
<%} // end if vRetResult==null %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

