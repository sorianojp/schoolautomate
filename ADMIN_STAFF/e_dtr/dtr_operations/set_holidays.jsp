<%@ page language="java" import="utility.*,java.util.Vector,eDTR.Holidays" %>
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
	var pgLoc = "./set_holidays_print.jsp?yyyy_to_view="+
		document.dtr_op.yyyy_to_view.value;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

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
	location = "./set_holidays.jsp";
}

function updateTypes(){
	var loadPg = "./set_holiday_types.jsp";
	var win=window.open(loadPg,"updateHolidayTypes",'dependent=yes,width=800,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
								"Admin/staff-eDaily Time Record-DTR OPERATIONS-Holiday Maintenance","set_holidays.jsp");
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
														"set_holidays.jsp");
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
Vector vRetEditResult= new Vector();
Holidays hol = new Holidays();
boolean bolFatalErr = true;
String strPageAction = WI.fillTextValue("page_action");
strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if(strPageAction.length() > 0){
	vRetResult = hol.operateOnCompanyHolidays(dbOP, request, Integer.parseInt(strPageAction));
	if(vRetResult == null)
		strErrMsg = hol.getErrMsg();
	else{
		strPrepareToEdit = "";
		strErrMsg = "Operation Successful";
	}
}
	
	vRetResult = hol.operateOnCompanyHolidays(dbOP, request, 4);


 if (strPrepareToEdit.compareTo("1") == 0){
	vRetEditResult = hol.operateOnCompanyHolidays(dbOP,request, 3);
	if (vRetEditResult == null){
		strErrMsg = hol.getErrMsg();
	}else{
		bolFatalErr = false;
	}
 }
%>
<form action="./set_holidays.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      HOLIDAY MAINTENANCE PAGE ::::</strong></font></td>
    </tr>
	    <tr>
      <td height="25"><font size=3><strong><%=strErrMsg%>&nbsp;</strong></font></td>
    </tr>
</table>	
  <table width="100%" border="0" align="center" bgcolor="#FFFFFF">
    <%if(!bolIsSchool || strSchCode.startsWith("VMUF") || strSchCode.startsWith("DBTC") ){%>
		<tr>
      <td>&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
			<%
			if(!bolFatalErr && (vRetEditResult != null && vRetEditResult.size() > 0))
				strTemp2 = (String)vRetEditResult.elementAt(5);
			else if(bolFatalErr)
				strTemp2 = WI.fillTextValue("c_index");
			%>
      <td>
			<select name="c_index">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strTemp2,false)%>
      </select>			</td>
    </tr>
		<%}%>
    <tr>
      <td>&nbsp;</td>
      <td>View Holiday for</td>
      <td>
<%
strTemp = WI.fillTextValue("yyyy_to_view");
if(strTemp.length() == 0) 
	strTemp = Integer.toString(java.util.Calendar.getInstance().get(java.util.Calendar.YEAR));
%>
	  <input name="yyyy_to_view" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('dtr_op','yyyy_to_view');style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('dtr_op','yyyy_to_view')">
        (YYYY) 
		&nbsp;&nbsp;<a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr>
      <td width="65">&nbsp;</td>
      <td width="114">Name of Holiday</td>
      <%
if(!bolFatalErr && (vRetEditResult != null && vRetEditResult.size() > 0)){
	strTemp2 = (String)vRetEditResult.elementAt(0);
	strTemp = (String) vRetEditResult.elementAt(1);
}else if(bolFatalErr){
	strTemp2 = WI.fillTextValue("hname");
	strTemp = WI.fillTextValue("hdate");
}

%>
      <td width="506"><input name="hname" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="a_address2" size="45" value="<%=strTemp2%>"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Date</td>
      <td><input name="hdate" type= "text" class="textbox"  readonly onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="hdate2" size="10" value="<%=strTemp%>"> 
        <a href="javascript:show_calendar('dtr_op.hdate');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
		
		<%
		if((vRetEditResult != null && vRetEditResult.size() > 0) || bolFatalErr )
			strTemp = "";
		else	
			strTemp = WI.fillTextValue("hdate_to");
		%>
		&nbsp;&nbsp;&nbsp;&nbsp;TO &nbsp;&nbsp;&nbsp;
		<input name="hdate_to" type= "text" class="textbox"  readonly onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="hdate3" size="10" value="<%=strTemp%>"> 
        <a href="javascript:show_calendar('dtr_op.hdate_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
		
		
		</td>
    </tr>

    <tr> 
      <td>&nbsp;</td>
      <td>Type of Holiday</td>
      <td><strong> 
        <%
if(!bolFatalErr && (vRetEditResult != null && vRetEditResult.size() > 0))
	strTemp2 = (String)vRetEditResult.elementAt(4);
else if(bolFatalErr)
	strTemp2 = WI.fillTextValue("hTypeIndex");

%>
        <select name="hTypeIndex">
          <option value="">Select Holiday type</option>
          <%=dbOP.loadCombo("holiday_type_index","type"," from edtr_holiday_type where is_del = 0 " +
					" and exists(select * from edtr_holiday_rate where is_valid = 1 " +
					"   and edtr_holiday_rate.holiday_type_index = edtr_holiday_type.holiday_type_index " +
					"   )" + 
					"order by TYPE asc",strTemp2, false)%> 
        </select>
				<%if(iAccessLevel > 1){%>
        <a href="javascript:updateTypes();"><img src="../../../images/update.gif" width="60" height="26" border="0"></a></strong><font size="1"> 
        click to update list of Holiday Types</font>
				<%}%>				</td>
    </tr>    
    <tr> 
      <td height="15" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="3" align="center"> 
				<%if(iAccessLevel > 1){%>
        <%if((strPrepareToEdit!=null) && (strPrepareToEdit.compareTo("1") == 0))
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
      <td> <a href="javascript:PrintPg();"><img src="../../../images/print.gif" align="right" border="0"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="5" align="center" class="thinborder"><strong>LIST 
      OF HOLIDAYS</strong></td>
    </tr>
    <tr>
      <%if(!bolIsSchool || strSchCode.startsWith("VMUF") || strSchCode.startsWith("DBTC")){%>
			<td width="20%" align="center" class="thinborder"><strong>
			  <%if(bolIsSchool){%>
			  College
			  <%}else{%>
			  Division
			  <%}%>
			</strong></td> 
			<%}%>
      <td width="30%" height="25" align="center" class="thinborder"><strong> &nbsp;NAME</strong></td>
      <td width="14%" align="center" class="thinborder"><strong>&nbsp;DATE</strong></td>
      <td width="19%" align="center" class="thinborder"><strong>&nbsp;TYPE OF HOLIDAY</strong></td>
      <td width="17%" align="center" class="thinborder"><strong>&nbsp;OPTIONS</strong></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size(); i+= 15) { %>
    <tr>
      <%if(!bolIsSchool || strSchCode.startsWith("VMUF") || strSchCode.startsWith("DBTC")){%>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "ALL")%></td> 
			<%}%>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><font size="1"> 
        <%if(iAccessLevel > 1){
	strTemp = (String)vRetResult.elementAt(i+3);
%>
        <a href='javascript:PrepareToEdit("<%=strTemp%>")'><img src="../../../images/edit.gif" alt="Edit Record" border="0"></a> 
        <%if(iAccessLevel == 2){%>
        <a href="javascript:DeleteRecord('<%=strTemp%>', '<%=vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" alt="Delete Record" border="0"></a> 
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

