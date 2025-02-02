<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function goToNextSearchPage()
{
//	document.schaccredited.editRecord.value = 0;
//	document.schaccredited.deleteRecord.value = 0;
//	document.schaccredited.addRecord.value = 0;
//	document.schaccredited.prepareToEdit.value = 0;

	document.schaccredited.submit();
}
</script>



<body bgcolor="#9FBFD0">
<form name="schaccredited" action="./accredited_school.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.Accredited,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
	int j = 0; // used to fill up the page with white boxes to make it apprear better .

//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}


//end of security code.
Accredited accredited = new Accredited();
int iSearchResult = 0;
Vector vRetResult = new Vector();
vRetResult = accredited.viewAllSCH(dbOP,request);
dbOP.cleanUP();

iSearchResult = accredited.iSearchResult;

if(vRetResult ==null)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="+2">
	<%=accredited.getErrMsg()%></font></p>
	<%
	return;
}

%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#47768F">
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>::::
          ACCREDITED SCHOOL LIST ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>


<%
if(vRetResult != null && vRetResult.size() >0)//6 in one set ;-)
{%>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td width="66%" ><b><font size="2" face="Verdana, Arial, Helvetica, sans-serif">
        Total Schools : <%=iSearchResult%> - Showing(<%=accredited.strDispRange%>)</font></b></td>
      <td width="34%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/accredited.defSearchSize;
		if(iSearchResult % accredited.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
          <select name="jumpto" onChange="goToNextSearchPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
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
          <%}%>
        </div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder"> 
    <tr> 
      <td width="13%" height="25" class="thinborder">&nbsp;<font size="1"><strong>SCHOOL CODE</strong></font></td>
      <td width="30%" class="thinborder">&nbsp;<font size="1"><strong>SCHOOL NAME</strong></font></td>
      <td width="16%" class="thinborder">&nbsp;<font size="1"><strong>SCHOOL TYPE</strong></font></td>
      <td width="39%" class="thinborder">&nbsp;<font size="1"><strong>ADDRESS</strong></font></td>
    </tr>
    <%

for(int i = 0; i< vRetResult.size(); ++i)
{++j;%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
    </tr>
    <%
i = i+4;
}//end of loop %>
  </table>

<%}//end of displaying %>

 </table>
 <table width="100%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
<%
if(j < 15)
for(; j< 15; ++j)
{%>
    <tr>
      <td>&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td>&nbsp;</td>
    </tr>
    <tr bgcolor="#47768F">
      <td height="25">&nbsp;</td>
    </tr>
  </table>

  </form>
</body>
</html>
