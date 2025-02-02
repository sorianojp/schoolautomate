<%@ page language="java" import="utility.*,purchasing.Endorsement,java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language='JavaScript'>
function ProceedClicked(){    
	document.form_.proceedClicked.value = "1";
	document.form_.printPage.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="endorsement_monthly_print.jsp"/>
	<%}
	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-ENDORSEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-ENDORSEMENT-Delete Endorsement details","endorsement_monthly.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	Endorsement EN = new Endorsement();	
 	Vector vRetResult = null;	
	String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
								"September","October","November","December"};	
	double dTemp = 0d;
	int iFieldCount = 12;
	int i = 0;
	boolean bolShowOffice = true;
	int iSearchResult = 0;

	String strCurColl = null;
	String strNextColl = null;
	String strCurDept = null;
	String strNextDept = null;
	
	if(WI.fillTextValue("proceedClicked").equals("1")){
		vRetResult = EN.getMonthlyIssuance(dbOP,request);
		iSearchResult = EN.getSearchCount();	
		if(vRetResult == null)
			strErrMsg = EN.getErrMsg();
		else
			iSearchResult = EN.getSearchCount();	
		
	}
%>
<form name="form_" method="post" action="endorsement_monthly.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          ENDORSEMENT - ENCODE/DELETE ENDORSEMENT DETAILS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
      <%
		String strCollegeIndex = WI.fillTextValue("c_index");
	  %>
      <td> <%if(bolIsSchool){%>College<%}else{%>Division<%}%> </td>
      <td> <select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Office</td>
      <td><select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="77%">&nbsp;<select name="year_of" onChange="ReloadPage();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
		</select> 
		<%
			strTemp = WI.fillTextValue("month_of");
		%>
		<select name="month_of">
          <%for(i = 0; i < 12; ++i){%>
		  	<%if(strTemp.equals(Integer.toString(i+1))){%>
          		<option value="<%=i+1%>" selected><%=astrConvertMonth[i]%></option>
		  	<%}else{%>
		  		<option value="<%=i+1%>"><%=astrConvertMonth[i]%></option>
			<%}%>	
          <%}%>
        </select></td>
		</tr>
    <tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"> <a href="javascript:ProceedClicked();"> <img src="../../../images/form_proceed.gif" border="0"> 
        </a></td>
    </tr>

  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" >
  	
  	<tr>
  	  <td width="3%" height="22" align="right">&nbsp;</td>
	    <td width="14%">Prepared by: </td>
			<%
				strTemp = WI.fillTextValue("prepared_by");
			%>
	    <td width="29%"><input type="text" name="prepared_by" maxlength="128" size="32" value="<%=strTemp%>"></td>
	    <td width="18%">&nbsp;</td>
	    <td width="18%">&nbsp;</td>
	    <td width="18%">&nbsp;</td>
    </tr>
  	<tr>
  	  <td height="22">&nbsp;</td>
	    <td height="22">Noted by : </td>
			<%
				strTemp = WI.fillTextValue("noted_by");
			%>
	    <td height="22"><input type="text" name="noted_by" maxlength="128" size="32" value="<%=strTemp%>"></td>
	    <td height="22">&nbsp;</td>
	    <td height="22">&nbsp;</td>
	    <td height="22">&nbsp;</td>
  	</tr>
  	<tr>		
      <td height="22" colspan="6" align="right"> <a href="javascript:PrintPage();"> 
        <img src="../../../images/print.gif" border="0"></a> <font size="1">click 
      to PRINT this endorsment records</font></td>
	</tr>
  	<tr>
		<%
		int iPageCount = iSearchResult/EN.defSearchSize;
		if(iSearchResult % EN.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%>		
  	  <td height="22" colspan="6" align="right">Jump To page:
  	    <select name="jumpto" onChange="ProceedClicked();">
  	      <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i = 1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
  	      <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
  	      <%}else{%>
  	      <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
  	      <%
				 }
			}
			%>
	      </select>
        <%}%></td>
	  </tr>  
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="6" align="center" class="thinborder"><font color="#FFFFFF"><strong>MONTHLY REPORT</strong></font></td>
    </tr>
    <tr> 
      <td width="11%" height="27" align="center" class="thinborder"><strong>DATE</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="11%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="47%" align="center" class="thinborder"><strong>ITEM / PARTICULARS / DESCRIPTION</strong></td>
      <td width="11%" align="center" class="thinborder"><strong>UNIT COST </strong></td>
      <td width="12%" align="center" class="thinborder"><strong>AMOUNT</strong></td>
    </tr>
    <%for(i = 0;i < vRetResult.size();i+=iFieldCount){ %>
	  <%if(bolShowOffice){
		bolShowOffice = false;
	  %>    
		<tr>
      <td height="26" colspan="6" class="thinborder">&nbsp;<%=(WI.getStrValue((String)vRetResult.elementAt(i+10),"OFFICE : ","","OFFICE : " + (String)vRetResult.elementAt(i+11))).toUpperCase()%></td>
    </tr>
		<%}%>
		<%
			if(i+iFieldCount+1 < vRetResult.size()){
				strCurColl = WI.getStrValue((String)vRetResult.elementAt(i+8),"");		
				strCurDept = WI.getStrValue((String)vRetResult.elementAt(i+9),"");	
			
				strNextColl = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount + 8),"");		
				strNextDept = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount + 9),"");		
				// System.out.println("strCurColl " + strCurColl);
				// System.out.println("strCurDept " + strCurDept);
				// System.out.println("strNextColl " + strNextColl);
				// System.out.println("strNextDept " + strNextDept);

				if(!(strCurColl).equals(strNextColl) || !(strCurDept).equals(strNextDept)){
					bolShowOffice= true;
				}		
			}
		%>
    <tr> 
      <td height="20" align="right" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i),"&nbsp;")%>&nbsp;</td>
      <td align="right" class="thinborder"><%=vRetResult.elementAt(i+1)%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i+3)%> / <%=vRetResult.elementAt(i+4)%><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"(",")","")%></td>
			<%
				strTemp = (String) vRetResult.elementAt(i+6);
				dTemp = Double.parseDouble(strTemp);
				strTemp  = CommonUtil.formatFloat(strTemp,true);
				if(dTemp == 0d)
					strTemp = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String) vRetResult.elementAt(i+7);
				dTemp = Double.parseDouble(strTemp);
				strTemp  = CommonUtil.formatFloat(strTemp,true);
				if(dTemp == 0d)
					strTemp = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
    </tr>

    <%
	//	 if(i < vRetResult.size()){
	//		 strCurColl = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount + 8),"");
	//		 strCurDept = WI.getStrValue((String)vRetResult.elementAt(i + iFieldCount + 9),"");
	//	 }	 	 		
		}// end for loop%>
    
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
  <%}%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25" colspan="8"></td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->  
  <input type="hidden" name="proceedClicked">
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="strIndex" value="">
  <input type="hidden" name="printPage" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
