<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
WebInterface WI = new WebInterface(request);


boolean bolIsBatchPrint = false;
if(WI.fillTextValue("batch_print").equals("1"))
	bolIsBatchPrint = true;

String strFontSize = "12";
int iCount = 0;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<style type="text/css">
	<!--
	body {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=strFontSize%>px;
	}
	td {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=strFontSize%>px;
	}
	th {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=strFontSize%>px;
	}
	@media print { 
	  @page {
	  		size:8.50in 6in; 
			margin-bottom:0in;
			margin-top:.1in;
			margin-right:.1in;
			margin-left:.1in;
		}
	}
	-->
	</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script>
function PrintPg() {
	<%if(!bolIsBatchPrint){%>
		window.print();
		if(confirm('Click OK to Finish Printing and Close this page'))
			window.close();	
	<%}%>

}
</script>
<body bottommargin="0" onLoad="PrintPg();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = 2;

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}




//add security here.
	try
	{
		dbOP = new DBOperation();
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

enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
enrollment.EnrlAddDropSubject enrlStudInfo = new enrollment.EnrlAddDropSubject();

boolean bolIsBasic = false;

String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};

//list of student id
Vector vStudList = new Vector();
//String strStudList = (String)request.getSession(false).getAttribute("stud_list");

vStudList.addElement(WI.fillTextValue("stud_id"));

/*request.getSession(false).removeAttribute("stud_list");

if(strStudList == null) {
	if(WI.fillTextValue("stud_id").length() > 0) 
		vStudList.addElement(WI.fillTextValue("stud_id"));	
}	
else 
	vStudList = CommonUtil.convertCSVToVector(strStudList);*/

String strStudID1     = null;
String strStudID2     = null;

String strSYFrom      = WI.fillTextValue("sy_from");
String strSYTo        = WI.fillTextValue("sy_to");
String strSemester    = WI.fillTextValue("offering_sem");
String strExamPeriod  = WI.fillTextValue("pmt_schedule");
String strExamName    = null;
if(strExamPeriod.length() > 0){
	strTemp = "select exam_name from fa_pmt_schedule where pmt_sch_index = "+strExamPeriod;
	strExamName = dbOP.getResultOfAQuery(strTemp, 0);
}

Vector vRetResult  = null;//get subject schedule information.
Vector vStudInfo1   = null; 

Vector vTerm1 = new Vector();
Vector vTerm2 = new Vector();

String strAdmSlipNo1   = null;
boolean bolPageBreak = false;
int iPrintCount = 0;
int iIndexOf = 0;

double dTotUnitTerm1 = 0d;
double dTotUnitTerm2 = 0d;

java.sql.ResultSet rs = null;
strTemp = " select e_sub_section.sub_sec_index, sub_code, sub_name, TERM_ESS  "+
		" from enrl_final_cur_list  "+
		" join E_SUB_SECTION on (E_SUB_SECTION.SUB_SEC_INDEX = ENRL_FINAL_CUR_LIST.SUB_SEC_INDEX) "+
		" join subject on (subject.SUB_INDEX = E_SUB_SECTION.SUB_INDEX) "+
		" where ENRL_FINAL_CUR_LIST.is_valid=1  "+
		" and ENRL_FINAL_CUR_LIST.sy_from="+strSYFrom+
		" and ENRL_FINAL_CUR_LIST.CURRENT_SEMESTER="+strSemester+
		" and ENRL_FINAL_CUR_LIST.user_index=?"+
		" and ENRL_FINAL_CUR_LIST.IS_TEMP_STUD=0";
java.sql.PreparedStatement pstmtGetTERM = dbOP.getPreparedStatement(strTemp);

if(vStudList != null && vStudList.size() > 0){
	while(vStudList.size() > 0){	
		
dTotUnitTerm2 = 0d;
dTotUnitTerm1 = 0d;
strStudID1    = null;
vTerm1 = new Vector();
vTerm2 = new Vector();
vStudInfo1    = null;
vRetResult   = null;
strAdmSlipNo1 = null;
		
strStudID1 = (String)vStudList.remove(0);	
vRetResult = reportEnrl.getStudentLoad(dbOP, strStudID1,strSYFrom, strSYTo, strSemester);
if(vRetResult == null || vRetResult.size() == 0)
	continue;

vStudInfo1 = (Vector)vRetResult.remove(0);
if(vStudInfo1 == null || vStudInfo1.size() == 0)
	continue;

strAdmSlipNo1 = reportEnrl.autoGenAdmSlipNum(dbOP, (String)vStudInfo1.elementAt(0),strExamPeriod, strSYFrom, strSemester);							



pstmtGetTERM.setString(1, (String)vStudInfo1.elementAt(0));
rs = pstmtGetTERM.executeQuery();
while(rs.next()){

	
iIndexOf = vRetResult.indexOf(rs.getString(3));//sub_name rs.getString(3)
if(iIndexOf == -1)
	continue;
	
if(rs.getInt(4) == 2){
	vTerm2.addElement(vRetResult.elementAt(iIndexOf - 1));	
	vTerm2.addElement(vRetResult.elementAt(iIndexOf));	
	vTerm2.addElement(vRetResult.elementAt(iIndexOf+1));	
	vTerm2.addElement(vRetResult.elementAt(iIndexOf+2));	
	vTerm2.addElement(vRetResult.elementAt(iIndexOf+3));	
	vTerm2.addElement(vRetResult.elementAt(iIndexOf+4));	
	vTerm2.addElement(vRetResult.elementAt(iIndexOf+5));	
	vTerm2.addElement(vRetResult.elementAt(iIndexOf+6));	
	vTerm2.addElement(vRetResult.elementAt(iIndexOf+7));	
	vTerm2.addElement(vRetResult.elementAt(iIndexOf+8));	
	vTerm2.addElement(vRetResult.elementAt(iIndexOf+9));			
}else{
	vTerm1.addElement(vRetResult.elementAt(iIndexOf - 1));	
	vTerm1.addElement(vRetResult.elementAt(iIndexOf));	
	vTerm1.addElement(vRetResult.elementAt(iIndexOf+1));	
	vTerm1.addElement(vRetResult.elementAt(iIndexOf+2));	
	vTerm1.addElement(vRetResult.elementAt(iIndexOf+3));	
	vTerm1.addElement(vRetResult.elementAt(iIndexOf+4));	
	vTerm1.addElement(vRetResult.elementAt(iIndexOf+5));	
	vTerm1.addElement(vRetResult.elementAt(iIndexOf+6));	
	vTerm1.addElement(vRetResult.elementAt(iIndexOf+7));	
	vTerm1.addElement(vRetResult.elementAt(iIndexOf+8));	
	vTerm1.addElement(vRetResult.elementAt(iIndexOf+9));		
}

}rs.close();

	
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="60" colspan="2" align="right" valign="middle"></td></tr>
	<tr>
	    <td width="53%" style="padding-left:120px;" height="60" valign="middle"><%=(String)vStudInfo1.elementAt(2)%> (<%=strStudID1%>)</td>
        <td width="47%" style="padding-left:100px;" valign="middle"><%=vStudInfo1.elementAt(3)%> - <%=WI.getStrValue(vStudInfo1.elementAt(4))%> &nbsp; <%=astrConvertSem[Integer.parseInt(strSemester)]%> SY <%=strSYFrom+"-"+strSYTo%></td>
	</tr>
	<tr>
	    <td style="padding-left:40px;" height="75" valign="bottom">&nbsp;</td>
	    <td valign="bottom">&nbsp;</td>
    </tr>
	<tr>
	    <td style="padding-left:40px;" height="60" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<%
				   iCount = 0;
				   for(int i=0 ; i< vTerm1.size(); i += 11, ++iCount){		   	
						strErrMsg = (String)vTerm1.elementAt(i);
						if(strErrMsg != null && strErrMsg.startsWith("NSTP") && strErrMsg.indexOf("(")> 0)
							strErrMsg = strErrMsg.substring(0, strErrMsg.indexOf("("));			
					%>
					  <tr>
						<td width="28%"><%=strErrMsg%></td>
						<%
						try{
							dTotUnitTerm1 += Double.parseDouble((String)vTerm1.elementAt(i+9));
						}catch(Exception e){}
						%>
						<td height="25" width="72%"><%=(String)vTerm1.elementAt(i+9)%></td>									
					  </tr>
				  <%}
				  if(iCount < 9){				  
				  for(int i = iCount; i < 9; i++){
				  %>
				  <tr><td colspan="2"  height="25">&nbsp;</td></tr>
				  <%}}
				   strTemp = Double.toString(dTotUnitTerm1);
				  if(dTotUnitTerm1 == 0d)
				  	strTemp = "";
				  %>
				  <tr><td height="18">&nbsp;</td>
				      <td height="25"><%=strTemp%></td>
				  </tr>
			</table>		</td>
	    <td height="60" valign="top">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<%			
					iCount = 0;	   
				   for(int i=0; i< vTerm2.size(); i += 11, ++iCount){		   	
						strErrMsg = (String)vTerm2.elementAt(i);
						if(strErrMsg != null && strErrMsg.startsWith("NSTP") && strErrMsg.indexOf("(")> 0)
							strErrMsg = strErrMsg.substring(0, strErrMsg.indexOf("("));			
					%>
					  <tr>
						<td width="28%"><%=strErrMsg%></td>
						<%
						try{
							dTotUnitTerm2 += Double.parseDouble((String)vTerm2.elementAt(i+9));
						}catch(Exception e){}
						%>
						<td height="25" width="72%"><%=(String)vTerm2.elementAt(i+9)%></td>									
					  </tr>
				  <%}
				  if(iCount < 9){				  
				  for(int i = iCount; i < 9; i++){
				  %>
				  <tr><td colspan="2"  height="25">&nbsp;</td></tr>
				  <%}}
				  strTemp = Double.toString(dTotUnitTerm2);
				  if(dTotUnitTerm2 == 0d)
				  	strTemp = "";
				  %>
				 <tr><td  height="25">&nbsp;</td>
				      <td height="18"><%=strTemp%></td>
				  </tr>
			</table>		</td>
    </tr>
	<tr>
	    <td height="60" colspan="2" valign="bottom" align="right" style="padding-right:50px;"><!--<%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%>--></td>
    </tr>
</table>


<%if(vStudList.size() > 0){%>
<div style="page-break-after:always;">&nbsp;</div>

<%}

}//end while
}//end vStudList != null && vStudList.size()
%>
</body>
</html>
<%
dbOP.cleanUP();
%>