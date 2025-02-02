<%
String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
if (strAuthID == null) {%>	
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		You are logged out. Please login again.</font></p>
<%return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">

function PageAction(strAction)
{
	if(document.form_.year_of.value.length != 4){
		alert("Please provide correct value for year of.");
		return;
	}
	
	if(document.form_.csv_area.value.length == 0){
		alert("No employee list found.");
		return;
	}
	
	if(!confirm("Do you want to upload this entries?"))
		return;
	
	document.form_.page_action.value=strAction;
	document.form_.submit();
	
}
function ResetPage()
{
	document.form_.page_action.value="";
	document.form_.csv_area.value = "";
	document.form_.submit();
}

function ViewUploaded(){
	var pgLoc = "./view_uploaded_prev_salary.jsp?year_of="+document.form_.year_of.value;	
	var win=window.open(pgLoc,"ViewUploaded",'width=800,height=600,top=20,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

</script>



<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	Vector vSecDetail = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-DTR"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Additional Month Pay","upload_prev_salary.jsp");
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


if(WI.fillTextValue("page_action").length() > 0){
	String strCSVData = WI.fillTextValue("csv_area");
	String strYearOf = WI.fillTextValue("year_of");
	if(strYearOf.length() == 0)
		strErrMsg = "Please provide correct value for year of.";
	else{
		if(strCSVData.length() == 0)
			strErrMsg = "No employee list found.";
		else{
			int iUserNotFound = 0;
			String strIDNumber = null;
			boolean bolDuplicate = false;
			try{							
				strTemp = " select PREVSAL_INDEX from  PR_PREV_SAL_DETAIL where IS_VALID = 1 "+
					" and YEAR_OF = "+strYearOf+" and USER_INDEX = ? and IS_PREVIOUS = 0 ";
				java.sql.PreparedStatement pstmtCheckDup = dbOP.getPreparedStatement(strTemp);
				
				strTemp = " insert into PR_PREV_SAL_DETAIL(USER_INDEX, YEAR_OF, BASIC_SAL, CREATE_DATE, ENCODED_BY,IS_PREVIOUS) "+
					" values(?, "+strYearOf+", ?,'"+WI.getTodaysDate()+"',"+strAuthID+",0) ";
				java.sql.PreparedStatement pstmtInsert = dbOP.getPreparedStatement(strTemp);
				
				strTemp = "update PR_PREV_SAL_DETAIL set BASIC_SAL = ? where is_valid =1 and user_index = ? and YEAR_OF = "+strYearOf;
				java.sql.PreparedStatement pstmtUpdate = dbOP.getPreparedStatement(strTemp);
				
				java.sql.ResultSet rs = null;
				String strUserIndex = null;
				double dSalary = 0d;
				Vector vEmpInfo = null;
				int iIndexOf = 0;				
				dbOP.forceAutoCommitToFalse();
				while( (iIndexOf = strCSVData.indexOf("\r\n")) > -1){
					iUserNotFound = 0;
					strUserIndex = null;
					dSalary = 0d;
					
					strErrMsg = strCSVData.substring(0,iIndexOf);					
					if(strErrMsg.endsWith(","))
						strErrMsg = strErrMsg.substring(0, strErrMsg.length() - 1);
					
					vEmpInfo = CommonUtil.convertCSVToVector(strErrMsg);
					
					if(vEmpInfo == null || vEmpInfo.size() != 2)
						throw new Exception();
					
					strIDNumber = (String)vEmpInfo.elementAt(0);
					strUserIndex = dbOP.mapUIDToUIndex(strIDNumber, -1);
					
					if(strUserIndex == null){
						iUserNotFound = 2;
						throw new Exception();
					}
					
					try{
						dSalary = Double.parseDouble((String)vEmpInfo.elementAt(1));
					}catch(NumberFormatException nfe){
						iUserNotFound = 1;
						throw new Exception();
					}
					
					
					
					bolDuplicate = false;
					pstmtCheckDup.setString(1, strUserIndex);
					rs = pstmtCheckDup.executeQuery();
					if(rs.next()){						
						bolDuplicate = true;
					}rs.close();
					
					if(bolDuplicate){
						if(WI.fillTextValue("overwrite_existing").length() > 0){
							pstmtUpdate.setDouble(1, dSalary);
							pstmtUpdate.setString(2, strUserIndex);
							pstmtUpdate.executeUpdate();
						}
						strCSVData = strCSVData.substring(iIndexOf+2);
						continue;
					}
						
					
					
					pstmtInsert.setString(1,strUserIndex);
					pstmtInsert.setDouble(2,dSalary);
					pstmtInsert.executeUpdate();
					
					strCSVData = strCSVData.substring(iIndexOf+2);
				}
				
				iUserNotFound = 0;
				strUserIndex = null;
				dSalary = 0d;
				
				if(strCSVData.endsWith(","))
					strCSVData = strCSVData.substring(0, strCSVData.length() - 1);
				vEmpInfo = CommonUtil.convertCSVToVector(strCSVData);				
				if(vEmpInfo == null || vEmpInfo.size() != 2)
					throw new Exception();				
					
				strIDNumber = (String)vEmpInfo.elementAt(0);				
				strUserIndex = dbOP.mapUIDToUIndex(strIDNumber, -1);					
				if(strUserIndex == null){
					iUserNotFound = 2;
					throw new Exception();
				}
				
				try{
					dSalary = Double.parseDouble((String)vEmpInfo.elementAt(1));
				}catch(NumberFormatException nfe){
					iUserNotFound = 1;
					throw new Exception();
				}				
				
				bolDuplicate = false;
				pstmtCheckDup.setString(1, strUserIndex);
				rs = pstmtCheckDup.executeQuery();
				if(rs.next()){						
					bolDuplicate = true;			
				}rs.close();
				
				if(bolDuplicate){
					if(WI.fillTextValue("overwrite_existing").length() > 0){
						pstmtUpdate.setDouble(1, dSalary);
						pstmtUpdate.setString(2, strUserIndex);
						pstmtUpdate.executeUpdate();
					}
				}else{
					pstmtInsert.setString(1,strUserIndex);
					pstmtInsert.setDouble(2,dSalary);
					pstmtInsert.executeUpdate();
				}				
				
				dbOP.commitOP();
				dbOP.forceAutoCommitToTrue();
				strErrMsg = "Employees previous salary information successfully uploaded.";
			}catch(java.sql.SQLException sqlE){
				sqlE.printStackTrace();
				dbOP.rollbackOP();
				strErrMsg = "Error in SQLQuery.";
			}catch(Exception e){				
				//e.printStackTrace();
				dbOP.rollbackOP();
				strErrMsg = "There is an error in uploading. Please check CSV format.";
				if(iUserNotFound == 1)
					strErrMsg = "Invalid Amount. Operation rolled back.";
				else if(iUserNotFound == 2)
					strErrMsg = "Employee ID : "+strIDNumber +" information not found. Operation rolled back.";			
			}
		}
	}
	
}


%>
<body bgcolor="#D2AE72">
<form name="form_" action="upload_prev_salary.jsp" method="post" >
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="7"><div align="center"><font color="#FFFFFF"><strong>::::
          UPLOAD PREVIOUS SALARY PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;<strong style="color:#FF0000">
	  <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></strong></td>
    </tr>
    
    
    
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	
	
	<tr>
	    <td height="25" colspan="3">Year Of&nbsp;&nbsp;	        <input name="year_of" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("year_of")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','year_of');style.backgroundColor='white'"	  
	  onKeyUp='AllowOnlyInteger("form_","year_of");'></td>
	    <td height="25">		</td>
	</tr>
	<tr>
		<td height="25" colspan="4">&nbsp;<strong>CSV values must be in format:<font color="#0000FF"> ID_NUMBER, SALARY(<font size="1" color="#FF0000">please remove comma in salary</font>) </font></strong></font></td>
      </tr>
	<tr>
	  <td height="25" valign="top">&nbsp;Example :  </td>
      <td width="38%" height="25"><strong>2476, 124767.77<br>
      2479, 10000.00<br>
      1178, 20500.00 </strong></td>
      <td width="52%"><a href="javascript:ViewUploaded()"><img src="../../../../images/view.gif" border="0"></a>
	  <font size="1">Click to view list of employee uploaded</font>
	  </td>
      <td height="25">&nbsp;</td>
	</tr>
	
	<tr>
	    <td colspan="4" height="25">
		<%
		strTemp = WI.fillTextValue("overwrite_existing");
		if(strTemp.length() > 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<input type="checkbox" name="overwrite_existing" value="1" <%=strErrMsg%>>Click to overwrite existing employee data.		</td>
	    </tr>
	<tr>
		<td width="6%">&nbsp;</td>
		<td colspan="2">
		
		<textarea rows="35" cols="75" name="csv_area" class="textbox"><%=WI.fillTextValue("csv_area")%></textarea></td>
		<td width="4%">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="4" align="center">
		<input type="button" name="1" value="<<< Upload Salary >>>" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('1');">	
		<font size="1">Click  to upload previous salary</font>
		<a href="javascript:ResetPage();"><img src="../../../../images/clear.gif" border="0"></a>
		<font size="1">Click to clear page</font>		</td>
	</tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
