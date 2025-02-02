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
<script language="JavaScript">

function PageAction(strAction, strInfoIndex){
	if(strAction == "0"){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
		
	document.form_.page_action.value = strAction;
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72" onLoad="Focus();">
<%@ page language="java" import="utility.*,enrollment.EntranceNGraduationData,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Graduates","grad_candidates.jsp");
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
														"Registrar Management","GRADUATES",request.getRemoteAddr(),
														"grad_candidates.jsp");
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

Vector vRetResult = new Vector();

String strSYFrom = WI.fillTextValue("sy_from");
String strSYTo = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");

if(strSYFrom.length() > 0 && strSemester.length() > 0){
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		int iAction = Integer.parseInt(strTemp);
		if(iAction == 0){
			if(WI.fillTextValue("info_index").length() == 0)
				strErrMsg = "Information reference is missing.";
			else{
				strTemp = "delete from GRADUATION_DATE_SETTING where SETTING_INDEX = "+WI.fillTextValue("info_index");
				if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) == -1){
					strErrMsg = "Error in SQLQuery.";
					System.out.println(strTemp);
				}
			}			
		}	
		if(iAction == 1){
			String strCIndex = WI.fillTextValue("c_index");
			if(strCIndex.length() == 0)
				strErrMsg = "Please select college.";
			else{
				String strDate = WI.fillTextValue("date_grad");
				strDate = ConversionTable.convertTOSQLDateFormat(strDate);
				if(strDate == null)
					strErrMsg = "Please provide graduation date in mm/dd/yyyy format.";
				else{
					strTemp = "select SETTING_INDEX from GRADUATION_DATE_SETTING where c_index = "+strCIndex;
					if(dbOP.getResultOfAQuery(strTemp, 0) != null)
						strErrMsg = "Cannot create duplicate entry.";
					else{
						strTemp = "insert into GRADUATION_DATE_SETTING(C_INDEX, GRADUATION_DATE, SY_FROM, SY_TO, SEMESTER) "+
						"values("+strCIndex+",'"+strDate+"',"+strSYFrom+","+strSYTo+","+strSemester+")";
						if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) == -1){
							strErrMsg = "Error in SQLQuery.";
							System.out.println(strTemp);
						}
					}
				}			
			}
		}		
	}
	
	strTemp = " select setting_index, college.C_INDEX, c_name, GRADUATION_DATE "+ 
			" from GRADUATION_DATE_SETTING "+
			" join COLLEGE on (COLLEGE.C_INDEX = GRADUATION_DATE_SETTING.C_INDEX) "+
			" where IS_DEL = 0 "+
			" and SY_FROM = "+strSYFrom+
			" and SEMESTER ="+strSemester;
	java.sql.ResultSet rs  =dbOP.executeQuery(strTemp);	
	while(rs.next()){
		vRetResult.addElement(rs.getString(1));
		vRetResult.addElement(rs.getString(2));
		vRetResult.addElement(rs.getString(3));
		vRetResult.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(4)));
	}rs.close();
	
}



%>
<form name="form_" action="./graduation_date_setting.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          DATE OF GRADUATION MANAGEMENT PAGE::::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td width="97%" height="25" colspan="4" ><font size="2"><strong><%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25" >&nbsp;</td>
      <td width="17%" height="25" >SY-Term</td>
      <td width="50%" height="25" >
<%
	if (WI.fillTextValue("sy_from").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	}else{
		strTemp = WI.fillTextValue("sy_from");
	}
%>
	  <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
<%
	if (WI.fillTextValue("sy_to").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	}else{
		strTemp = WI.fillTextValue("sy_to");
	}
%>
        <input name="sy_to" type="text" class="textbox" id="sy_to" readonly
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4">
        &nbsp; 
<%
	strTemp = WI.fillTextValue("semester");
	if(strTemp.length() == 0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	if(strTemp == null) strTemp = "";
%>
        <select name="semester" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
<%

if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>
		<input type="image" src="../../../images/refresh.gif" border="0">
		</td>
      <td width="30%" ></td>
    </tr>
    
        
  </table>

 
 <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">	
	
 	<tr>
 	    <td height="25">&nbsp;</td>
 	    <td>College</td>
 	    <td>
		<select name="c_index" style="width:300px;">
			<%
			strTemp = WI.fillTextValue("c_index");
			strErrMsg = " from college where is_del =0 and is_college =1 order by c_name";
			%>
			<%=dbOP.loadCombo("c_index","c_name", strErrMsg, strTemp, false)%>
		</select>		</td>
 	    </tr>
 	<tr>
 	    <td width="3%" height="25">&nbsp;</td>
 	    <td width="17%">Graduation Date</td>
		<%
		strTemp = WI.fillTextValue("date_grad");		
		%>
 	    <td width="80%"><input name="date_grad" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_grad');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
 	    </tr>
 	
	
	
	
	
	<tr>
	    <td height="25">&nbsp;</td>
	    <td valign="top">&nbsp;</td>
	    <td>			
			<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
			<font size="1">Click to save information</font>			</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td valign="top">&nbsp;</td>
	    <td>&nbsp;</td>
	    </tr>
 </table>
 
<%
if(vRetResult != null && vRetResult.size() >0){
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
	<tr style="font-weight:bold;">
		<td class="thinborder" width="43%" height="25" align="center">COLLEGE</td>
		<td class="thinborder" width="33%" align="center">GRADUATION DATE</td>
		<td class="thinborder" width="24%" align="center">DELETE</td>
	</tr>
	<%for(int i = 0; i < vRetResult.size(); i+=4){%>
	<tr>
	    <td class="thinborder" height="25"><%=vRetResult.elementAt(i+2)%></td>
	    <td class="thinborder" align="center"><%=vRetResult.elementAt(i+3)%></td>
	    <td class="thinborder" align="center">
		<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a>
		</td>
	    </tr>
	<%}%>
</table>

<%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
