<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../../jscript/common.js"></script>
<script language="JavaScript">
function RefreshPage(){
    document.form_.subject.value="";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
 	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	WebInterface WI = new WebInterface(request);

    //add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Subject Offered Per SY-Term","sy_term_offered_per_subjects.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Registrar Management","REPORTS",request.getRemoteAddr(), 
															"sy_term_offered_per_subjects.jsp");	
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}

    //end of authenticaion code.
    java.sql.ResultSet  rs = null;
	Vector vRetResult = new Vector();
	
	String[] astrSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};	
	
	if(WI.fillTextValue("subject").length()>0){	
	        strTemp = " select distinct offering_sy_from, offering_sy_to, offering_sem, sem_order from e_sub_section join semester_sequence on (semester_val = offering_sem) "+					
						" 	where e_sub_section.is_valid=1 and e_sub_section.is_del=0 and e_sub_section.SUB_INDEX="+ WI.fillTextValue("subject")+ 
						" 	order by OFFERING_SY_FROM desc, sem_order desc ";
	    rs = dbOP.executeQuery(strTemp);		
		while(rs.next()){		
				vRetResult.addElement(rs.getString(1));
				vRetResult.addElement(rs.getString(2));
				vRetResult.addElement(rs.getString(3));			
		}
		rs.close();			
		if(vRetResult.size()==0)
		   strErrMsg="No result found. ";
	}
%>
<form name="form_" action="./sy_term_offered_per_subjects.jsp" method="post">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
	  <font color="#FFFFFF"><strong>:::: SUBJECT OFFERING PER SY-TERM ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">       
	<tr>
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>	
	<tr >
      <td width="5%" height="25">&nbsp;</td>
      <td width="12%">Subject s</td>
      <td colspan="4">
	  <% 
	  	strTemp = " from subject where is_del =0  "+
		" and exists( "+
		" 	select  * from CURRICULUM where IS_VALID = 1 "+
		" 	and SUB_INDEX = subject.SUB_INDEX and course_index > 0 "+
		" ) and exists (select sub_sec_index from e_sub_section where sub_index = subject.sub_index and is_valid = 1) "+
		" order by sub_code "; 
	 	%>
	  <select name="subject" style="width:400px;" onChange="document.form_.submit();" >	
	  <option value="">Select Subject</option>	
	  <%=dbOP.loadCombo("distinct sub_index"," sub_code, sub_name ",strTemp,WI.fillTextValue("subject") , false)%>
	  </select>
  </td>
    </tr>
	
     <tr > 
      <td height="24" colspan="2">&nbsp;</td>
      <td height="24" colspan="4">
	  <a href="javascript:RefreshPage();">
	  <img src="../../../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>  
  <% if(vRetResult!=null && vRetResult.size()>0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A">
	  <div align="center"><font color="#FFFFFF"><strong>:::: LIST OF SY-TERM OFFERED ::::</strong></font></div></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr style="font-weight:bold;" bgcolor="#FFFF99">
   <td width="43%" height="25" class="thinborder">School Year</td>
   <td width="57%" class="thinborder">Semester</td>
  </tr>
  <% for (int i=0; i<vRetResult.size(); i+=3){%>
  <tr> 
     <td class="thinborder" height="22">
	 <%=WI.getStrValue((String)vRetResult.elementAt(i),"&nbsp;")%> - 
	 <%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%> </td>
	 <td class="thinborder"><%=WI.getStrValue(astrSem[Integer.parseInt((String)vRetResult.elementAt(i+2))] ,"&nbsp;")%></td>  
  </tr>
  <%}//en dof vRetResult loop%>
  </table>
  <%}//end of vRetResult !=null && vRetResult.size()>0%>
<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="subject">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>