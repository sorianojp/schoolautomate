<%@ page language="java" import="utility.*,java.util.Vector,hr.HRSalaryGrade"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.

boolean bolIsSchool = false;

if ((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle_small.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
TD{
	font-size:11px;
}

  TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;
  } 
	TD.thinborderLEFT {
    border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;
  } 
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex,strAction) {
	document.form_.page_action.value = strAction;
	if(strAction == "1") {
		document.form_.hide_save.src = "../../../images/blank.gif";
		
//		alert (document.form_.jump_to.length);
//		alert (document.form_.jump_to.selectedIndex);		
		
		if (document.form_.jump_to.selectedIndex == document.form_.jump_to.length-1){
			document.form_.jump_to.selectedIndex--;	
		}
	}
	document.form_.submit();
}

function UpdateSelection(){
	var iMaxDisplay = document.form_.max_display.value;
	if (document.form_.select_all.checked) {
		for( var i =0 ; i < iMaxDisplay ; i++){
			if (eval('document.form_.benefit_index'+i+'.checked == false'))
				eval('document.form_.benefit_index'+i+'.checked = true');
		}
	}else{
		for( var i =0 ; i < iMaxDisplay ; i++){
			eval('document.form_.benefit_index'+i+'.checked = false');
		}
	}
}

function ReloadPage(){
	document.form_.reload_page.value = "1";
	document.form_.submit();
}

function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	this.SubmitOnce("form_");
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iCtr = 0;
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-Personnel","emp_benefits.jsp.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = -1;
														
if (!strSchCode.startsWith("AUF")){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
												(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"emp_benefits.jsp.jsp");
}else{
  iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
	 											(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"hr_personnel_service_rec_benefit.jsp");
}														
														
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home",
						"../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
Vector vRetResult = null;
Vector vEmpBenefits = null;
int j = 0;
int i = 0;
hr.hrAutoInsertBenefits hrAuto = new hr.hrAutoInsertBenefits();
boolean bolPageBreak = false;
	vRetResult = hrAuto.getEmployeeBenefitIncentive(dbOP,request);
	if (vRetResult != null) {	
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){
%>

<body onLoad="javascript:window.print();">
<form name="form_">
 		<table width="100%" border="0"cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="4" align="center" class="thinborder"><strong>EMPLOYEE BENEFITS AND INCENTIVES </strong></td>
    </tr>
		<%
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=20, ++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			
	 	vEmpBenefits = (Vector)vRetResult.elementAt(i+12);
	 %>
    <tr>
      <td height="22" colspan="4" class="thinborderLEFT">
	  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0"> 
	  	<tr> 
		  	<td width="50%" height="25"> Name :<font color="#FF0000"><strong><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), 
																																						(String)vRetResult.elementAt(i+4), 4)%> (<%=(String)vRetResult.elementAt(i+1)%>)</strong></font></td>	  
		  	<td width="50%">Date of Employment :<strong><font color="#0000FF"><%=(String)vRetResult.elementAt(i+5)%> </font></strong></td>
	    </tr>
	  </table></td>
    </tr>
		<%if(vEmpBenefits != null && vEmpBenefits.size() > 0){%>
    <tr>
      <td width="6%" height="18" class="thinborder">&nbsp;</td>
      <td width="94%" height="18" colspan="3" class="thinborderBOTTOM"><table width="100%" border="0" cellspacing="0" cellpadding="0">
				<%for(j = 0; j < vEmpBenefits.size(); j+=10){%>
        <tr>					
          <td width="25%" height="21"><%=(String)vEmpBenefits.elementAt(j+2)%> </td>
					<% 
						strTemp =(String)vEmpBenefits.elementAt(j+4); 
					%>
          <td width="25%"><%=strTemp%></td>
					
          <td width="25%">&nbsp;</td>
          <td width="25%">&nbsp;</td>
        </tr>
				<%}%>
      </table></td>
      </tr>
		<%}
		}%>
  </table>

  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>