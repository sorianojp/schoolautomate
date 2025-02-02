<%@ page language="java" import="utility.*,java.sql.ResultSet,java.sql.SQLException,java.util.Vector,java.util.Calendar" %>
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
<title>Summary of Employee Timein/Timeout</title>
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

	.fontsize11{
		font-size : 11px;
	}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function searchEmployee()
{	
	document.form_.search_employee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
</script>

<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	if(WI.fillTextValue("print_page").equals("1")) {%>
		<jsp:forward page="./summary_emp_leaves_print.jsp" />		
	<%return;}
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;	
	Vector vRetResult = null;

	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Reports & Statistics-Summary Emp with Leaves","summary_emp_leaves_uncredited.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();		
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"summary_emp_tin_tout.jsp");	
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

%>
<form action="./summary_emp_tin_tout.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF"><strong>:::: 
      SUMMARY OF EMPLOYEES TIME IN/TIME OUT PAGE ::::</strong></font></td>
    </tr>
  </table>
  
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Date</td>
      <td><input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        to 
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
    	&nbsp;&nbsp;
	 <input name="proceed" type="image" onClick="searchEmployee();" src="../../../images/form_proceed.gif"> 	
	 </td>

    </tr>
    <tr> 
      <td height="19" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  
  
    
<%

//if proceed if clicked
if(WI.fillTextValue("search_employee").equals("1")){
	//start of getting all employees' tintout
	boolean bolIsFirstLoop = true;
	boolean bolIsValid = true;
	String strSQLQuery = null;
	String strDateFrom = null;
	String strDateTo   = null;
	String strCurrentId = "";
	ResultSet rs  = null;	
	long lTimeIn  = 0l;
	long lTimeOut = 0l;
	int iTimeIn   = 0;
	int iTimeOut  = 0;
	int iTemp = 0;
	Calendar cal  = Calendar.getInstance();
	
	try{		
		strTemp = "";
		strDateFrom = WI.fillTextValue("date_fr");
		strDateTo = WI.fillTextValue("date_to");
		if (strDateFrom != null && strDateFrom.length() > 0)
			 strDateFrom = ConversionTable.convertTOSQLDateFormat(strDateFrom);		
		
      	if (strDateTo != null && strDateTo.length() > 0)
			 strDateTo = ConversionTable.convertTOSQLDateFormat(strDateTo);				 	
		
    	if (strDateTo == null || strDateTo.length() == 0 || strDateFrom == null || strDateFrom.length() == 0 ){
			bolIsValid = false;
			strErrMsg = "Invalid date entry.";	
		}else{
			strSQLQuery = " select id_number,TIMEIN_DATE,TIME_IN,TIMEOUT_DATE,TIME_OUT,AM_PM_SET " +
					 " from EDTR_TIN_TOUT " +
					 " join USER_TABLE on (USER_table.USER_INDEX = EDTR_TIN_TOUT.USER_INDEX) " +
				     " where edtr_tin_tout.IS_DEL = 0 and edtr_tin_tout.IS_VALID = 1 " +	
					 " and USER_table.IS_VALID = 1 and USER_table.is_del = 0 "  +	
					 " and timein_date >= '" + strDateFrom + "' and timein_date<='" + strDateTo + "'" +				 	
					 " order by id_number,TIMEIN_DATE asc ";
			rs = dbOP.executeQuery(strSQLQuery);		
		}//end of if valid
		
	}catch (SQLException sqle) {
          strErrMsg = "Error in connection. Please try again.";
          String strErrorToLog = "Error in sql Query : " + strSQLQuery;         
          sqle.printStackTrace();
          System.out.println(strSQLQuery);          
    }
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
 
<%
if(bolIsValid){
 while(rs.next()){%>	 
  
   	<%if(bolIsFirstLoop){%>	
	  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0"  >
		<tr> 
		  <td  width="8%" height="25" align="center"   ><strong><font size="1">EMPLOYEE ID</font></strong></td>
		  <td width="24%" align="center"  ><strong><font size="1">DATE </font></strong></td>
		  <td width="17%" align="center"  ><strong><font size="1">TIME</font></strong></td>
		  <td width="15%" align="center"  ><strong>STATUS</strong></td>     
		</tr>
    <%
		bolIsFirstLoop = false;
	} //end of bolIsFirstLoop = true %>
	
    <tr>  
      <td height="25"  >&nbsp;<%=rs.getString(1)%></td>
      <td  >&nbsp;<%=ConversionTable.convertMMDDYYYY(rs.getDate(2))%></td>	
	  <%
	  	 lTimeIn = rs.getLong(3);	  
		 cal.setTimeInMillis(lTimeIn);
		 iTimeIn = cal.get(Calendar.HOUR_OF_DAY);
		 iTemp   = cal.get(Calendar.MINUTE); 		
		 strTemp = "" + iTimeIn;
		 if (iTemp < 10)
			strTemp += ":0" + iTemp;
		 else
			strTemp += ":" + iTemp;
	  %>  
      <td  >&nbsp;<%=strTemp%></td>
	  <td   align="center">1</td>     
    </tr>
	<%
		strTemp = ConversionTable.convertMMDDYYYY (rs.getDate(4));
	if(strTemp != null && strTemp.length() > 0 ){ //if there is time out %>
	<tr>
      <td height="25"  >&nbsp;<%=rs.getString(1)%></td>
  	  <%
	  	 lTimeOut = rs.getLong(5);	  
		 cal.setTimeInMillis(lTimeOut);
		 iTimeOut = cal.get(Calendar.HOUR_OF_DAY); 
		 iTemp   = cal.get(Calendar.MINUTE); 		
		 strTemp2 = "" + iTimeOut;
		 if (iTemp < 10)
			strTemp2 += ":0" + iTemp;
		 else
			strTemp2 += ":" + iTemp;
			
	  if(lTimeOut < lTimeIn ){ //if timeout < timein, next day logout, add 1 day 
	  	 cal.add(Calendar.DAY_OF_MONTH, 1);	
		 strTemp = ConversionTable.convertMMDDYYYY(cal.getTime());	
	  }%> 
	   <td  >&nbsp;<%=strTemp%></td>
	  <td  >&nbsp;<%=strTemp2%></td>
	  <td   align="center">0</td>         
    </tr>
	<%}//if there is timeout %>
<%	strCurrentId = rs.getString(1); 
}//while rs.next()
 if(!bolIsFirstLoop){ //end table tag if there is at least result%>
   </table>  
  <%}//end of has result
  }//end of if valid  
 }//end of if proceed is clicks %>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25">&nbsp;</td>
      <td width="31%">&nbsp;</td>
    </tr>
  </table>  
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="search_employee" >

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>