<%@ page language="java" import="utility.*,java.util.Vector,eDTR.OverTime" %>
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
<title>Overtime Group Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>

<script>
<!--
function PrintPg() {	
	

}
function AddRecord(){
	document.dtr_op.print_pg.value = "";

	document.dtr_op.page_action.value ="1";
	document.dtr_op.submit();
}
function DeleteRecord(strTargetIndex, strHolName)
{
	if(!confirm("Continue deleting " + strHolName + "?"))
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
	location = "./overtime_group_mgt.jsp";
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
								"Admin/staff-eDaily Time Record-DTR OPERATIONS-Holiday Maintenance","overtime_group_mgt.jsp");
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
														"overtime_group_mgt.jsp");
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
OverTime overtime = new OverTime();
boolean bolFatalErr = true;
String strPageAction = WI.fillTextValue("page_action");
strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if(strPageAction.length() > 0){
	vRetResult = overtime.operateOnOvertimeGrouping(dbOP, request, Integer.parseInt(strPageAction));
	if(vRetResult == null)
		strErrMsg = overtime.getErrMsg();
	else{
		strPrepareToEdit = "";
		strErrMsg = "Operation Successful";
	}
}	
	vRetResult = overtime.operateOnOvertimeGrouping(dbOP, request, 4);	

 if (strPrepareToEdit.compareTo("1") == 0){
	vEditInfo = overtime.operateOnOvertimeGrouping(dbOP,request, 3);
	if (vEditInfo == null){
		strErrMsg = overtime.getErrMsg();
	}else{
		bolFatalErr = false;
	}
 }
%>
<form action="overtime_group_mgt.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      OVERTIME GROUP MANAGEMENT PAGE ::::</strong></font></td>
    </tr>
	    <tr>
      <td height="25"><font size=3><strong><%=strErrMsg%>&nbsp;</strong></font></td>
    </tr>
</table>	
  <table width="100%" border="0" align="center" bgcolor="#FFFFFF">      
    <tr>
      <td width="65">&nbsp;</td>
      <td width="114">Group Name</td>
      <%
if(!bolFatalErr &&(vEditInfo != null && vEditInfo.size() > 0)){	
	strTemp = (String) vEditInfo.elementAt(1);
}else if(bolFatalErr){
	strTemp = WI.fillTextValue("group_name");	
}

%>
      <td width="506"><input name="group_name" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="a_address2" size="45" value="<%=strTemp%>"></td>
    </tr>
   <tr>	
   			<td width="65">&nbsp;</td>
		  <td width="18%" height="25">
		  	Remarks </td>
		  <td>	
		  <% 
		  	if(!bolFatalErr &&(vEditInfo != null && vEditInfo.size() > 0)){	
				strTemp =  (String) vEditInfo.elementAt(2);
			}else{
				strTemp = WI.fillTextValue("description"); 
			}		
		  %> 
		  	<textarea name="description" cols="48" rows="3" class="textbox" 
	  onfocus="CharTicker('form_','256','remarks','count_');style.backgroundColor='#D3EBFF'" 
	  onBlur ="CharTicker('form_','256','remarks','count_');style.backgroundColor='white'" 
	  onkeyup="CharTicker('form_','256','remarks','count_');"><%=strTemp%></textarea>
              <br>
              <font size="1">Available Characters</font> 
              <input name="count_" type="text" class="textbox_noborder" size="5" maxlength="5" readonly="yes" tabindex="-1">
		  </td>
	 </tr>
   
    <tr> 
      <td height="15" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="3" align="center"> 
				<%if(iAccessLevel > 1){%>
        <%if((strPrepareToEdit!=null) && (strPrepareToEdit.compareTo("1") == 0))
{%>
        <a href="javascript:EditRecord();"><img src="../../../../images/edit.gif" width="40" height="26" border="0"></a><font size="1">click 
          to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../../images/cancel.gif" width="51" height="26" border="0"></a> 
        <font size="1">click to cancel or go previous</font> 
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../../images/save.gif" border="0"></a><font size="1">click 
          to add</font> 
        <%}%>
				<%}%>      </td>
    </tr>
	<!-- <tr>  <td colspan="3"><hr size="1"></td> </tr> -->
  </table>
<% if (vRetResult !=null && vRetResult.size() > 0){ %>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">      
    <tr> 
		<td> &nbsp; </td>
	</tr>
	<!--
	<tr> 
      <td> <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" align="right" border="0"></a></td>
    </tr>
	-->
  </table>
  
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">  
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="5" align="center" class="thinborder"><strong>LIST 
      OF GROUPS </strong></td>
    </tr>
    <tr>
      
	  <td width="5%" align="center" class="thinborder"><strong>&nbsp;</strong></td> 
      <td width="30%" height="25" align="center" class="thinborder"><strong> &nbsp;GROUP NAME</strong></td>
      <td width="45%" align="center" class="thinborder"><strong>&nbsp;DESCRIPTION</strong></td>      
      <td align="center" class="thinborder"><strong>&nbsp;OPTIONS</strong></td>
    </tr>
    <% for (int i = 0, iCtr = 1; i < vRetResult.size(); i+= 3, iCtr++) { %>
    <tr>     
	  <td class="thinborder" align="center">&nbsp;<%=iCtr%></td>	
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>     
      <td class="thinborder"><font size="1"> 
        <%if(iAccessLevel > 1){
	strTemp = (String)vRetResult.elementAt(i);
%>
        <a href='javascript:PrepareToEdit("<%=strTemp%>")'><img src="../../../../images/edit.gif" alt="Edit Record" border="0"></a> 
        <%if(iAccessLevel == 2){%>
        <a href="javascript:DeleteRecord('<%=strTemp%>', '<%=vRetResult.elementAt(i+1)%>')"><img src="../../../../images/delete.gif" alt="Delete Record" border="0"></a> 
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

