<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
  /*this is what we want the div to look like*/
  div.processing{
    display:block;
    /*set the div in the bottom right corner*/
    position:absolute;
    right:7;
	top:10;
    width:300px;
	height:150;/** it expands on its own.. **/
    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-group oth sch fee","oth_sch_fee_group_spc.jsp");
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
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"oth_sch_fee_group_spc.jsp");
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
Vector vRetResult = new Vector();
java.sql.ResultSet rs = null;
String strSQLQuery = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(strTemp.equals("0"))
		strSQLQuery = "delete from FA_OTH_SCH_FEE_GROUP where fosft = "+WI.fillTextValue("info_index");
	else {
		if(WI.fillTextValue("group_name").length() == 0)
			strErrMsg = "Please enter group name.";
		else if(WI.fillTextValue("fee_amt").length() == 0)
			strErrMsg = "Please enter Fee Amount applicable for this group.";
		else {
			strSQLQuery = "insert into FA_OTH_SCH_FEE_GROUP(fee_name_t, group_name,group_fee_amt) values ('"+ConversionTable.replaceString(WI.fillTextValue("fee_name"),",","")+"',"+
						WI.getInsertValueForDB(WI.fillTextValue("group_name"), true, null)+","+
						ConversionTable.replaceString(WI.fillTextValue("fee_amt"),",","")+")";
		}
	}
	if(strSQLQuery != null) {
		if(dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) == -1) 
			strErrMsg = "Error in Processing. Please try again.";
		else	
			strErrMsg = "Request Processed successfully.";
	}

}

strSQLQuery = "select fosft, group_name, fee_name_t,group_fee_amt  from FA_OTH_SCH_FEE_GROUP order by group_name";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vRetResult.addElement(rs.getString(1));
	vRetResult.addElement(rs.getString(2));
	vRetResult.addElement(rs.getString(3));
	vRetResult.addElement(CommonUtil.formatFloat(rs.getDouble(4), true));
}
rs.close();
Vector vSummary = new Vector();
if(vRetResult.size() > 0) {
	strSQLQuery = "select group_name, sum(group_fee_amt) from FA_OTH_SCH_FEE_GROUP group by group_name order by group_name";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vSummary.addElement(rs.getString(1));
		vSummary.addElement(rs.getString(2));
	}
	rs.close();
}

%>
<form name="form_" action="./oth_sch_fee_group_spc.jsp" method="post">
		  <div id="processing" class="processing"  style="visibility:visible; overflow:auto">
		  	<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#FFCC99">
				<tr><td valign="top">
					<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
					  <tr>
						<td colspan="2" valign="top" align="right" height="20" class="thinborder"><a href="javascript:HideLayerGroupFee(1)">Close Window X</a></td>
					  </tr>
					  <%while(vSummary.size() > 0) {%>
						<tr>
							<td height="20" width="70%" class="thinborder"><%=vSummary.remove(0)%></td>
							<td width="30%" class="thinborder"><%=vSummary.remove(0)%></td>
						</tr>
					  <%}%>
					</table>
				</td></tr>
			</table>
          </div>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: Group Other School Fee ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>  
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%">Fee Name (Ungrouped) </td>
      <td width="80%">
	  	<select name="fee_name">
<%
strTemp = " from fa_oth_sch_fee where is_valid = 1 "+//and not exists (select * from FA_OTH_SCH_FEE_GROUP where FEE_NAME_T = fee_name) "+
			" order by fa_oth_sch_fee.fee_name";
%>					
<%=dbOP.loadCombo("distinct fa_oth_sch_fee.fee_name","fa_oth_sch_fee.fee_name",strTemp, WI.fillTextValue("fee_name"), false)%>
		</select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Group Name </td>
      <td>
	  <input name="group_name" type="text" class="textbox" size="32" maxlength="32" onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("group_name")%>" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee Amount </td>
      <td><input name="fee_amt" type="text" class="textbox" size="10" maxlength="12" onFocus="style.backgroundColor='#D3EBFF'" value="<%=WI.fillTextValue("fee_amt")%>" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%if(iAccessLevel > 1) {%>
	  <input type="submit" name="12" value="&nbsp;&nbsp;Save Information&nbsp;&nbsp;" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'">
<%}%>	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2" bgcolor="#dddddd"><div align="center"><strong>::: List of Other School Fee Grouped ::: </strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
    <tr> 
      <td width="15%" class="thinborder" style="font-size:9px; font-weight:bold">Group Name </td>
      <td width="60%" height="25" class="thinborder" style="font-size:9px; font-weight:bold" align="center">&nbsp;Fee Name</td>
      <td width="15%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Fee Amount </td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Delete</td>
    </tr>
    
<%
String strBGColor = "";
String strGroupName = null;
for(int i=0; i<vRetResult.size(); i+=4){
	if(strGroupName == null) 
		strGroupName = (String)vRetResult.elementAt(i + 1);
	else {
		if(!strGroupName.equals((String)vRetResult.elementAt(i + 1))) {
			strGroupName = (String)vRetResult.elementAt(i + 1);
			if(strBGColor.length() == 0)
				strBGColor   = " bgcolor='#cccccc'";
			else	
				strBGColor   = "";
		}
	}
	%>
    <tr<%=strBGColor%>> 
      <td height="25" class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder" align="center">
		<input type="submit" name="12" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='0';document.form_.info_index.value='<%=vRetResult.elementAt(i)%>'">	  </td>
    </tr>
    <%}%>
  </table>
<%}//end of display. %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->

<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
