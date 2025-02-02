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
<title>Overtime Group-Type Management</title>
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
	location = "./overtime_group_mapping.jsp";
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
								"Admin/staff-eDaily Time Record-DTR OPERATIONS-Holiday Maintenance","overtime_group_mapping.jsp");
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
														"overtime_group_mapping.jsp");
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
	vRetResult = overtime.operateOnOTGroupTypeMapping(dbOP, request, Integer.parseInt(strPageAction));
	if(vRetResult == null)
		strErrMsg = overtime.getErrMsg();
	else{
		strPrepareToEdit = "";
		strErrMsg = "Operation Successful";
	}
}	
	vRetResult = overtime.operateOnOTGroupTypeMapping(dbOP, request, 4);
%>
<form action="overtime_group_mapping.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      OVERTIME GROUP-TYPE PAGE ::::</strong></font></td>
    </tr>
	    <tr>
      <td height="25"><font size=3><strong><%=strErrMsg%>&nbsp;</strong></font></td>
    </tr>
</table>	
  <table width="100%" border="0" align="center" bgcolor="#FFFFFF">      
    <tr>
      <td width="125">&nbsp;</td>
	  <td width="140">Overtime Group</td>
	  <%		
		strTemp = WI.fillTextValue("ot_group_index");
		strTemp = WI.getStrValue(strTemp,"0");
	  %>		
      <td width="694" height="26">
			<select name="ot_group_index">				
				<%=dbOP.loadCombo("ot_group_index","ot_group_name"," from EDTR_OT_GROUP order by ot_group_name asc",strTemp, false)%> 
			</select> 
	  </td>	  
    </tr>
	
	<tr>
      <td width="125">&nbsp;</td>
	  <td width="140">Overtime Type</td>
	  <%
		strTemp = WI.fillTextValue("ot_type_index");
		strTemp = WI.getStrValue(strTemp,"0");
	  %>		
	  <td width="694" height="26">
      <select name="ot_type_index">
              <option value="">None</option>
              <%=dbOP.loadCombo("ot_type_index","ot_name", " from pr_ot_mgmt " +
		 					 " where is_valid = 1 and is_for_ot = 1 ", strTemp,false)%>
       </select>  
	   </td>
    </tr>

    <tr> 
      <td height="15" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="3" align="center"> 
		<%if(iAccessLevel > 1){%>        
        <a href="javascript:AddRecord();"><img src="../../../../images/save.gif" border="0"></a><font size="1">click 
          to add</font> 
        <%}%>
	</td>
    </tr>
	<!-- <tr>  <td colspan="3"><hr size="1"></td> </tr> -->
  </table>
<% if (vRetResult !=null && vRetResult.size() > 0){ %>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">      
    <tr> 
		<td>&nbsp;  </td>
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
    <% 	String strPrev = "";
		for (int i = 0; i < vRetResult.size(); i+= 4) { 
			if(!strPrev.equals((String)vRetResult.elementAt(i+1))){ %>
			<tr>
	  			<td  colspan="5" height="25" class="thinborder"><strong> &nbsp;<%=(String)vRetResult.elementAt(i+1)%></strong></td>	  
			</tr>
		<%
			strPrev = (String)vRetResult.elementAt(i+1); 
		}//end of if diff group name %>
	<tr>
	  <td width="30%" class="thinborder">&nbsp;</td>	
      <td width="50%" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>      
      <td width="20%" class="thinborder"><font size="1"> 
        <%if(iAccessLevel > 1){
	strTemp = (String)vRetResult.elementAt(i);
%>        
        <%if(iAccessLevel == 2){%>
        <a href="javascript:DeleteRecord('<%=strTemp%>', '<%=vRetResult.elementAt(i+2)%>')"><img src="../../../../images/delete.gif" alt="Delete Record" border="0"></a> 
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

